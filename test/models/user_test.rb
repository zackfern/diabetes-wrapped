require "test_helper"

class UserTest < ActiveSupport::TestCase
  VALID_USER = User.first

  test "email address must be valid" do
    user = VALID_USER.dup
    user.email = "not-an-email"
    refute user.valid?

    user.email = "zack@example.com"
    assert user.valid?
  end

  test "requires a valid Nightscout Host" do
    user = VALID_USER.dup
    user.nightscout_host = "not a domain"
    refute user.valid?

    user.nightscout_host = "domain.with.no.scheme.com"
    refute user.valid?

    user.nightscout_host = "http://http.domain.com"
    assert user.valid?

    user.nightscout_host = "https://https.domain.com"
    assert user.valid?
  end

  test "requires a Nightscout Token" do
    user = VALID_USER.dup
    user.nightscout_token = nil
    refute user.valid?

    user.nightscout_token = ""
    refute user.valid?

    user.nightscout_token = "abc-123"
    assert user.valid?
  end

  test "requires valid range min/max ranges" do
    user = VALID_USER.dup
    user.range_min = nil
    refute user.valid?

    user.range_min = "Not a Number"
    refute user.valid?

    user.range_min = 60
    user.range_max = "Not a Number"
    refute user.valid?

    user.range_min = 70
    user.range_max = 160
    assert user.valid?
  end
end
