# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def signup_email
    UserMailer.with(user: User.first).signup_email
  end
end
