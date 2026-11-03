class Report < ApplicationRecord
  enum :status, [ :not_started, :in_progress, :finished ], default: :not_started

  belongs_to :user
  has_many :months, class_name: "ReportMonth", dependent: :destroy
end
