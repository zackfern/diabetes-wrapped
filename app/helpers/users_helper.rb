module UsersHelper
  # Returns a String of `<option>` tags for timezones.
  #
  # This differs from the built-in `time_zone_options_for_select` method because its values
  # are standard IANA time zone names (America/Los_Angeles) instead of Rails-specific values
  # (Pacific Time (US & Canada)). This allows us to use JavaScript to set the value in browser.
  #
  #
  def timezone_options_for_select(selected)
    options = ActiveSupport::TimeZone.all.collect do |tz|
      offset = ActiveSupport::TimeZone.seconds_to_utc_offset(tz.utc_offset)
      [ "(UTC#{offset}) #{tz.name}", tz.tzinfo.name ]
    end

    options_for_select(options, selected)
  end
end
