class ReportMonth < ApplicationRecord
  # ReportMonth statuses:
  # - in_progress - The MonthlyReportJob started on the month but didn't finish it.
  #   Shouldn't happen unless the job fails midway.
  # - incomplete - The MonthlyReportJob did as much as it could, but was run on a month
  #   that hasn't finished yet. E.g. the user generates the report on November 15th.
  # - finished - The ReportMonth contains complete data.
  enum :status, [ :in_progress, :incomplete, :finished ], default: :in_progress

  belongs_to :report
end
