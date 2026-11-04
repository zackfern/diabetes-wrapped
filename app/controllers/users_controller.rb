class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:current_user_id] = @user.id
      # redirect_to new_report_path
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
    params.require(:user).permit(:email, :nightscout_host, :nightscout_token)
  end
end
