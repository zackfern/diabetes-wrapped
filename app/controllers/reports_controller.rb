class ReportsController < ApplicationController
  def show
    @report = Report.find_by_slug(params[:slug])
    @months = @report.months.to_a
    @highest_bg = @months.collect(&:highest_bg).max
    @lowest_bg = @months.collect(&:lowest_bg).min

    if @report.finished?
      render :show
    else
      render :in_progress
    end
  end
end
