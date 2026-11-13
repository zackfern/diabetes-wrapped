class MonthlyReportJob < ApplicationJob
  queue_as :default

  attr_accessor :report, :month_report
  delegate :user, to: :report
  delegate :nightscout, to: :user

  around_perform do |job, block|
    # Find the Report first, since we call `user` below which delegates to @report:
    @report = Report.find(job.arguments.first)

    # Ensure that we use the correct timezone when the `perform` method is run:
    Time.use_zone(user.timezone) { block.call }
  end

  def perform(report_id, month)
    # Heads up, we find @report in the around_perform method above.

    # Set the report status if it hasn't already been set:
    report.update(status: :in_progress) unless report.in_progress?

    @report_month = report.months.find_or_initialize_by(month:)

    @first_day = Time.local(@report.year, month, 1).to_datetime
    @last_day = @first_day.end_of_month

    # If the last day of the month hasn't happened yet, set the last day we'll query to today:
    @last_day = Time.current.to_datetime if @last_day.future?

    blood_glucose_stats
    @report_month.assign_attributes({
      highest_bg: @blood_glucose[:highest_value],
      highest_bg_date: Time.zone.parse(@blood_glucose[:highest]["dateString"]),
      lowest_bg: @blood_glucose[:lowest_value],
      lowest_bg_date: Time.zone.parse(@blood_glucose[:lowest]["dateString"]),
      days_in_range: @days_in_range,
      wake_ups: @nightly_wakeups,
      readings_in_range: @blood_glucose[:readings_in_range],
      readings_out_of_range: @blood_glucose[:readings_out_of_range]
    })

    if report.include_insulin?
      # Save calculated glucose stats, just in case:
      @report_month.save

      insulin_stats
      @report_month.assign_attributes({
        total_insulin: @insulin[:total_units],
        total_bolus: @insulin[:bolus_units],
        total_basal: @insulin[:basal_units],
        bolus_count: @insulin[:bolus_count],
        biggest_bolus: @insulin[:biggest_bolus],
        biggest_bolus_date: @insulin[:biggest_bolus_date]
      })
    end

    if @last_day != @first_day.end_of_month
      # If the last day we processed isn't the end of the month,
      # mark the ReportMonth as incomplete so it can be re-generated in the future:
      @report_month.update({ status: :incomplete })
    else
      @report_month.update({ status: :finished })
    end

    # Enqueue the next job or wrap up:
    if month < 12
      # Don't enqueue a job if the next month hasn't happened yet:
      if (@last_day + 1).future?
        ReportOrchestrationJob.perform_later(report_id)
      else
        MonthlyReportJob.perform_later(report_id, month + 1)
      end
    else
      ReportOrchestrationJob.perform_later(report_id)
    end
  end

  private

  def blood_glucose_stats
    @blood_glucose = {
      highest_value: 0,
      lowest_value: Float::INFINITY,
      highest: nil,
      lowest: nil,
      readings_in_range: 0,
      readings_out_of_range: 0
    }
    @days_in_range = 0
    @nightly_wakeups = 0

    # Iterate over every day in the month and request entries from Nightscout:
    (@first_day..@last_day).each do |day|
      entries = nightscout.on_date(day)
      woken_up = false
      reading_in_range, reading_out_of_range = 0, 0

      entries.each do |entry|
        if entry["sgv"] > @blood_glucose[:highest_value]
          @blood_glucose[:highest_value] = entry["sgv"]
          @blood_glucose[:highest] = entry
        elsif entry["sgv"] < @blood_glucose[:lowest_value]
          @blood_glucose[:lowest_value] = entry["sgv"]
          @blood_glucose[:lowest] = entry
        end

        if entry["sgv"] >= user.range_max
          reading_out_of_range += 1
        elsif entry["sgv"] <= user.range_min
          reading_out_of_range += 1

          # Don't calculate if we've already been woken up on this day:
          unless woken_up
            occurred_at = Time.zone.parse(entry["dateString"])
            woken_up = occurred_at.hour.between?(0, 6)
          end
        else
          reading_in_range += 1
        end
      end

      # If there were no out-of-range readings, count that as a day in range:
      @days_in_range += 1 if reading_out_of_range == 0

      # If we went below our range, assume we were woken up to deal with it:
      @nightly_wakeups += 1 if woken_up

      # Add in/out of range to total monthly stats:
      @blood_glucose[:readings_in_range] += reading_in_range
      @blood_glucose[:readings_out_of_range] += reading_out_of_range
    end
  end

  def insulin_stats
    @insulin = {
      total_units: 0.0,
      basal_units: 0.0,
      bolus_count: 0,
      bolus_units: 0.0,
      biggest_bolus: 0.0,
      biggest_bolus_date: nil
    }

    # Iterate over every day in the month and request entries from Nightscout:
    (@first_day..@last_day).each do |day|
      treatments = nightscout.treatments_on_date(day)

      temp_basals = []
      treatments.each do |treatment|
        if treatment["eventType"].include?("Bolus")
          next unless treatment["insulin"].is_a?(Numeric)

          @insulin[:bolus_count] += 1
          @insulin[:bolus_units] += treatment["insulin"]
          @insulin[:total_units] += treatment["insulin"]

          if treatment["insulin"] > @insulin[:biggest_bolus]
            @insulin[:biggest_bolus] = treatment["insulin"]
            @insulin[:biggest_bolus_date] = Time.zone.parse(treatment["created_at"])
          end
        elsif treatment["eventType"] == "Temp Basal"
          duration = treatment["duration"]
          next if duration.nil? || duration.zero?
          next if treatment["created_at"].nil?

          start_time = Time.zone.parse(treatment["created_at"])
          temp_basals << {
            start_time:,
            end_time: start_time + duration,
            value: treatment["absolute"]
          }
        end
      end

      profile = profile_for_day(day)
      basals = profile.dig("store", profile["defaultProfile"], "basal")
        .sort_by { it["timeAsSeconds"] }
        .reverse

      # Backfill normal basal rates around the temp basal rates:
      basal_deliveries = temp_basals.inject([]) do |memo, segment|
        last_basal = memo.reverse.find { it[:end_time] < segment[:start_time] }
        start_time = last_basal&.dig(:end_time) || day.midnight

        # Find the basal rate from our profile:
        basal = basals.find { |basal| basal["timeAsSeconds"] <= start_time.seconds_since_midnight }

        # Create a new segment which starts either after the last end_time (or at midnight) and ends when our temp rate begins:
        memo << { start_time:, end_time: segment[:start_time], value: basal["value"] }

        # And then add this temp rate to the list:
        memo << segment

        # Always return the memo last:
        memo
      end

      total_basal = basal_deliveries.sum { |s| s[:value] * (s[:end_time] - s[:start_time]) / 1.hour.to_f }.round
      @insulin[:basal_units] += total_basal
      @insulin[:total_units] += total_basal
    end
  end

  def profile_for_day(day)
    @profiles ||= Rails.cache.fetch(@report.profiles_cache_key, expires_in: 1.hour) {
      nightscout.profile
    }
    @profiles.find { it["startDate"] <= day } || @profiles.first
  end
end
