class ReportOrchestrationJob < ApplicationJob
  queue_as :high

  def perform(report_id, action: nil)
    @report = Report.find(report_id)

    if @report.not_started?
      MonthlyReportJob.perform_now(report_id, 1)
    elsif @report.incomplete? || action == :rerun
      incomplete_month = @report.months.last.month
      MonthlyReportJob.perform_now(report_id, incomplete_month)
    elsif @report.in_progress? || @report.finished?
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

    months = @report.months.to_a
    months.each do |month|
      attrs.each_key do |key|
        next if month[key].nil?
        attrs[key] += month[key]
      end
    end

    # Set the report status to match the last month's status.
    # If it's finished, the report is finished. If it's incomplete, so is this report:
    last_month = months.sort_by(&:month).last
    attrs[:status] = last_month.status

    @report.update(attrs)
  end
end
