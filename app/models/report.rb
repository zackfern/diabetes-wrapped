class Report < ApplicationRecord
  enum :status, [ :not_started, :in_progress, :finished ], default: :not_started

  belongs_to :user
  has_many :months, class_name: "ReportMonth", dependent: :destroy

  after_initialize do |record|
    record.slug ||= "#{RandomNonsense.adjective_food_diabetes}-#{rand(1921)}"
  end

  delegate :unit, to: :user

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

  def incomplete?
    # Report is incomplete if the last day of the year hasn't happened yet:
    Time.use_zone(user.timezone) do
      DateTime.new(year, 12, -1).end_of_day.future?
    end
  end
end
