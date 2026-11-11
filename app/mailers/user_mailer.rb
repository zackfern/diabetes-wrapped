class UserMailer < ApplicationMailer
  def signup_email
    @user = params[:user]
    @report = @user.report
    mail(to: @user.email, subject: "Your Diabetes Wrapped")
  end
end
