class ReportsController < ApplicationController
  def show
    @report = Report.find_by_slug(params[:slug])

    if @report.finished?
      render :show
    else
      render :in_progress
    end
  end
end
