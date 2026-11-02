class ReportMonth < ApplicationRecord
  belongs_to :report
  enum :status, [ :in_progress, :finished ]
end
