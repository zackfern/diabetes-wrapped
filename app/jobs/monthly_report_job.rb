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
    report.update(status: :in_progress) if report.not_started?

    @report_month = report.months.find_or_initialize_by(month:)

    @first_day = Time.local(@report.year, month, 1).to_datetime
    @last_day = @first_day.end_of_month

    # If the last day of the month hasn't happened yet, set the last day we'll query to today:
    @last_day = Time.current.to_datetime if @last_day.future?

    blood_glucose_stats
    @report_month.assign_attributes({
      highest_bg: @blood_glucose[:highest_value],
      highest_bg_date: Time.parse(@blood_glucose[:highest]["dateString"]).to_date,
      lowest_bg: @blood_glucose[:lowest_value],
      lowest_bg_date: Time.parse(@blood_glucose[:lowest]["dateString"]).to_date,
      days_in_range: @days_in_range
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

    @report_month.update({ status: :finished })

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
      lowest: nil
    }
    @days_in_range = 0

    # Iterate over every day in the month and request entries from Nightscout:
    (@first_day..@last_day).each do |day|
      entries = nightscout.on_date(day)
      reading_in_range, reading_out_of_range = 0, 0

      entries.each do |entry|
        if entry["sgv"] > @blood_glucose[:highest_value]
          @blood_glucose[:highest_value] = entry["sgv"]
          @blood_glucose[:highest] = entry
        elsif entry["sgv"] < @blood_glucose[:lowest_value]
          @blood_glucose[:lowest_value] = entry["sgv"]
          @blood_glucose[:lowest] = entry
        end

        if entry["sgv"] > user.range_max || entry["sgv"] < user.range_min
          reading_out_of_range += 1
        else
          reading_in_range += 1
        end
      end

      # If there were no out-of-range readings, count that as a day in range:
      @days_in_range += 1 if reading_out_of_range == 0
    end
  end

  def insulin_stats
    @insulin = {
      total_units: 0,
      basal_units: 0,
      bolus_count: 0,
      bolus_units: 0,
      biggest_bolus: 0,
      biggest_bolus_date: nil
    }

    # Iterate over every day in the month and request entries from Nightscout:
    (@first_day..@last_day).each do |day|
      treatments = nightscout.treatments_on_date(day)

      treatments.each do |treatment|
        next unless treatment["insulin"].present? && treatment["insulin"] > 0
        @insulin[:total_units] += treatment["insulin"]

        if treatment["eventType"].include?("Bolus")
          @insulin[:bolus_count] += 1
          @insulin[:bolus_units] += treatment["insulin"]

          if treatment["insulin"] > @insulin[:biggest_bolus]
            @insulin[:biggest_bolus] = treatment["insulin"]
            @insulin[:biggest_bolus_date] = treatment["created_at"]
          end
        else
          # FIXME: Add Basal stats!
        end
      end
    end
  end
end
