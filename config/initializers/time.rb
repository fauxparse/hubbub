Date::DATE_FORMATS[:date_picker] = '%a, %d %b %Y'

Date::DATE_FORMATS[:fuzzy] = lambda do |date|
  today = Date.today
  if date == today
    "today"
  elsif date < today
    case d = today - date
    when 1 then "yesterday"
    when 2..7 then (date.wday >= today.wday ? "last" : "on") + " #{date.strftime('%A')}"
    when 8..30 then (date.day > today.day) ? "last month" : Numb3rs.pluralize((d / 7).to_i, "week") + " ago"
    when 31..365 then Numb3rs.pluralize((d / (1.month / 1.day)).to_i, "month") + " ago"
    else date.strftime "on #{date.day} %B %Y"
    end
  else
    case d = date - today
    when 1 then "tomorrow"
    when 2..7 then "on #{date.strftime('%A')}"
    when 8..30 then "in " + Numb3rs.pluralize((d / 7).to_i, "week")
    when 31..365 then "in " + Numb3rs.pluralize((d / (1.month / 1.day)).to_i, "month")
    else date.strftime "on #{date.day} %B %Y"
    end
  end
end

module Numb3rs
  def self.pluralize(number, word, *options)
    [ number.in_words(*options), (number == 1 ? word : ActiveSupport::Inflector.pluralize(word)) ] * " "
  end
end
