class ReportsController < ApplicationController
  before_action :find_report, except: [ :in_progress ]

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
