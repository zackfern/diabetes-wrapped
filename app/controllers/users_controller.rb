class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # If the user is invalid, re-render the sign-up form:
    unless @user.valid?
      @cap_token = params["cap-token"]
      render action: :new, status: :unprocessable_entity
      return
    end

    # Nightscout only returns data in mg/dL, so if the user uses mmol/L
    # we need to convert their ranges from mmol/L to mg/dL internally:
    if @user.unit == "mmol/L"
      @user.range_min = (@user.range_min * 18.016).round
      @user.range_max = (@user.range_max * 18.016).round
    end

    # If enabled, validate Cap token to prevent bots from signing up:
    if helpers.use_cap?
      unless validate_cap_token
        flash[:error] = "Sorry, we couldn't verify that you aren't a bot."
        redirect_to :root, status: :unprocessable_entity
      end
    end

    if @user.save
      session[:current_user_id] = @user.id

      latest_treatment = @user.nightscout.latest_treatment
      @report = @user.build_report(include_insulin: latest_treatment.present?)

      if @report.save
        UserMailer.with(user: @user).signup_email.deliver_later
        ReportOrchestrationJob.perform_later(@report.id)
        redirect_to report_path(@report.slug)
      end
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(login_token: params[:token])
    session[:current_user_id] = @user.id

    if @user.present?
      flash[:notice] = "Welcome back!"
      redirect_to :root
    else
      flash[:error] = "Something went wrong and we couldn't log you in."
      redirect_to :root
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

  def validate_cap_token
    response = Cap.new.validate(params["cap-token"])
    response.dig("success") == true
  end
end
