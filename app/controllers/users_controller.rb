class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # Nightscout only returns data in mg/dL, so if the user uses mmol/L
    # we need to convert their ranges from mmol/L to mg/dL internally:
    if @user.unit == "mmol/L"
      @user.range_min = (@user.range_min * 18.016).round
      @user.range_max = (@user.range_max * 18.016).round
    end

    if @user.save
      session[:current_user_id] = @user.id

      latest_treatment = @user.nightscout.latest_treatment
      @report = @user.build_report(include_insulin: latest_treatment.present?)

      if @report.save
        ReportOrchestrationJob.perform_later(@report.id)
        redirect_to report_path(@report.slug)
      end
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def logout
    reset_session
    redirect_to :root
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :nightscout_host,
      :nightscout_token,
      :range_max,
      :range_min,
      :timezone,
      :unit,
    )
  end
end
