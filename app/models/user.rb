class User < ApplicationRecord
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates :nightscout_host, format: URI::DEFAULT_PARSER.make_regexp
  validates :nightscout_token, presence: true
  validates :range_min, :range_max, numericality: true

  has_one :report

  def nightscout
    @nightscout ||= Nightscout.new(nightscout_host, nightscout_token)
  end
end
