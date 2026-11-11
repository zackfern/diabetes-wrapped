Time::DATE_FORMATS[:date_with_time] = lambda { |time|
  day_format = ActiveSupport::Inflector.ordinalize(time.day)
  time.strftime("%A, %B #{day_format} at %I:%M %p")
}
