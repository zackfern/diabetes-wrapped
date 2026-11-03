class ReportMonth < ApplicationRecord
  enum :status, [ :in_progress, :finished ], default: :in_progress

  belongs_to :report
end
