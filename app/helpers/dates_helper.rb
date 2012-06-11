# encoding: utf-8

module DatesHelper
  def when_in_the_past(date)
    seconds_in_past = Time.now - date
    
    s = seconds_in_past.floor
    
    if s >= 0.seconds and s < 2.seconds
      "#{s} second ago"
    elsif s >= 2.seconds and s < 1.minute
      "#{s} seconds ago"
    elsif s >= 1.minute and s < 2.minutes
      "1 minute ago"
    elsif s >= 2.minutes and s < 1.hour
      s = (s/60).floor
      "#{s} minutes ago"
    elsif s >= 1.hour and s < 2.hours
      "1 hour ago"
    elsif s >= 2.hours and s < 1.day
      s = (s/(60*60)).floor
      "#{s} hours ago"
    elsif s >= 1.day and s < 2.days
      "1 day ago"
    elsif s >= 2.days and s < 1.month
      s = (s/(60*60*24)).floor
      "#{s} days ago"
    elsif s >= 1.month and s < 2.months
      "1 month ago"
    elsif s >= 2.months and s < 1.year
      s = (s/(60*60*24*30)).floor
      "#{s} months ago"
    elsif s >= 1.year and s < 2.years
      "1 year ago"
    else
      s = (s/(60*60*24*365))
      "#{s} years ago"
    end
  end
end
