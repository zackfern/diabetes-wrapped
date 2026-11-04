class Report < ApplicationRecord
  enum :status, [ :not_started, :in_progress, :finished ], default: :not_started

  belongs_to :user
  has_many :months, class_name: "ReportMonth", dependent: :destroy

  after_initialize do |record|
    record.slug ||= "#{RandomNonsense.adjective_food_diabetes}-#{rand(1921)}"
  end
end
