class ReportOrchestrationJob < ApplicationJob
  queue_as :default

  def perform(report_id)
    @report = Report.find(report_id)

    if @report.not_started?
      MonthlyReportJob.perform_now(report_id, 1)
    elsif @report.in_progress?
      finish_report!
    end
  end

  private

  def finish_report!
    attrs = {
      total_insulin: 0.0,
      total_basal: 0.0,
      total_bolus: 0.0,
      bolus_count: 0,
      days_in_range: 0,
      wake_ups: 0,
      readings_in_range: 0,
      readings_out_of_range: 0
    }

    @report.months.each do |month|
      attrs.each_key do |key|
        attrs[key] += month[key]
      end
    end

    attrs[:status] = :finished
    @report.update(attrs)
  end
end
