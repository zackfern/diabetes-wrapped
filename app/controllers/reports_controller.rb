class ReportsController < ApplicationController
  before_action :find_report, except: [ :in_progress ]
  before_action :authenticate_user, only: [ :status, :download, :rerun ]

  def show
    @months = @report.months.to_a

    @highest_bg = { value: 0, timestamp: nil, instances: 1 }
    @lowest_bg = { value: Float::INFINITY, timestamp: nil, instances: 1 }
    @months.each do |month|
      if month.highest_bg >= @highest_bg[:value]
        # If the value is equal to the current value, bump the instances:
        if @highest_bg[:value] == month.highest_bg
          @highest_bg[:instances] += 1
        else
          @highest_bg[:value] = month.highest_bg
          @highest_bg[:timestamp] = month.highest_bg_date
        end
      end

      if month.lowest_bg <= @lowest_bg[:value]
        if @lowest_bg[:value] == month.lowest_bg
          @lowest_bg[:instances] += 1
        else
          @lowest_bg[:value] = month.lowest_bg
          @lowest_bg[:timestamp] = month.lowest_bg_date
        end
      end
    end

    if @report.visible?
      render :show
    else
      render :in_progress
    end
  end

  def status
    render json: {
      visible: @report.visible?,
      months: @report.months.finished.count
    }
  end

  def download
    respond_to do |f|
      f.csv do
        send_data @report.to_csv, filename: "diabetes-wrapped-#{@report.year}.csv"
      end
    end
  end

  def rerun
    unless @report.can_be_rerun?
      flash[:error] = "It's too soon to re-run your report, please try again later."
      redirect_to report_path(slug: @report.slug); return
    end

    # Update to in_progress, so ReportController#show won't render it.
    if @report.update_attribute(:status, :in_progress)
      # Force the rerun action, so the default behavior of the orhcestrator doesn't run.
      ReportOrchestrationJob.perform_later(@report.id, action: :rerun)

      flash[:notice] = "We're updating your report with the latest information..."
      redirect_to report_path(slug: @report.slug)
    else
      flash[:error] = "Something went wrong and we couldn't re-run your report."
      redirect_to report_path(slug: @report.slug)
    end
  end

  private
  def find_report
    @report = Report.find_by_slug(params[:slug])
    render_404 unless @report.present?
  end

  def authenticate_user
    unless session[:current_user_id] == @report.user_id
      render plain: "Unauthorized", status: :unauthorized
    end
  end
end
