class User < ApplicationRecord
  UNITS = [ "mg/dL", "mmol/L" ]

  validates :email, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true
  validates :nightscout_host, format: URI::DEFAULT_PARSER.make_regexp
  validates :nightscout_token, presence: true
  validates :range_min, :range_max, numericality: true
  validates :unit, inclusion: { in: UNITS }
  validates_with NightscoutValidator, on: :create

  has_one :report, dependent: :destroy

  after_initialize do |record|
    record.login_token ||= Random.uuid
  end

  def nightscout
    @nightscout ||= Nightscout.new(nightscout_host, nightscout_token)
  end
end
