class ReportsController < ApplicationController
  before_action :find_report, except: [ :in_progress ]

  def show
    @months = @report.months.to_a
    @highest_bg = @months.collect(&:highest_bg).max
    @lowest_bg = @months.collect(&:lowest_bg).min

    if @report.finished?
      render :show
    else
      render :in_progress
    end
  end

  def status
    render json: {
      status: @report.status,
      months: @report.months.finished.count
    }
  end

  private
  def find_report
    @report = Report.find_by_slug(params[:slug])
    render_404 unless @report.present?
  end
end
