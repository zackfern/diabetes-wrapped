class Report < ApplicationRecord
  # Report statuses:
  # - not_started - Report is created, but the first MonthlyReportJob hasn't run yet.
  # - in_progress - The MonthlyReportJob is working on generating the report.
  # - incomplete - The Report is as generated as it can be, and is visible to the user,
  #   but doesn't contain complete stats for the year.
  # - finished - The Report is complete, visible, and represents the entire year.
  #   This will only happen for reports generated or re-run in the following calendar year.
  enum :status, [ :not_started, :in_progress, :incomplete, :finished ], default: :not_started

  belongs_to :user
  has_many :months, class_name: "ReportMonth", dependent: :destroy

  after_initialize do |record|
    record.slug ||= "#{RandomNonsense.adjective_food_diabetes}-#{rand(1921)}"
  end

  delegate :unit, to: :user

  def visible?
    incomplete? || finished?
  end

  def profiles_cache_key
    "#{user.id}-profiles"
  end

  def boluses_per_day
    (bolus_count / days_for_calculation).round
  end

  def wake_up_frequency
    (days_for_calculation / wake_ups.to_f).round
  end

  def days_for_calculation
    created_at.yday
  end

  def vial_estimate
    # Vials of insulin have 1000 each:
    (total_insulin / 1000.0).round(1)
  end

  def total_readings
    readings_in_range + readings_out_of_range
  end

  def in_range_percentage
    in_range_percentage = (readings_in_range.to_f / total_readings) * 100
    in_range_percentage.round(1)
  end

  def to_csv
    our_months = months.to_a
    excluded_attributes = %w[id status report_id created_at updated_at]
    attributes = our_months.first.attribute_names - excluded_attributes

    CSV.generate(headers: true) do |csv|
      # Set the headers as the attributes on ReportMonth:
      csv << attributes

      # For each month, add an item with each of the attributes:
      our_months.each do |month|
        csv << attributes.map { |attr| month[attr] }
      end
    end
  end
end
