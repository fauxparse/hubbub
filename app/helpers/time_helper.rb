module TimeHelper
  def graph_recent_activity(times, end_date = nil, options = {})
    end_date ||= Date.today
    start_date = end_date - 1.month
    result = ""
    result << content_tag(:h2, options.delete(:heading) || describe_date_range(start_date, end_date)) unless options[:heading] == false
    result << "<ul class=\"timeline\">"
    dates = (start_date..end_date).to_a
    hours = dates.collect { |d| times.select { |t| t.date == d }.sum(Hour[0], &:recorded_time) }
    hours_per_day = dates.zip hours
    max_hours = 10
    
    hours_per_day.each_with_index do |x, i|
      d, h = x
      result << content_tag(:li, link_to(content_tag(:span, d.day, :class => :label) + graph_bar(d, h), "#", :class => "d#{d.to_s}") + ((i == 0 && d.day < 25) || d.day == 1 ? content_tag(:span, d.strftime("%B %Y"), :class => "month") : ""), :class => ((d.wday + 1) % 7 < 2 ? "weekend" : "weekday"))
    end
    result << "</ul>"
    result << clear_floats
    content_tag :div, result, options.reverse_merge(:class => "graph")
  end
  
  def graph_bar(d, h)
    content_tag(:span, "(#{h.to_s(:fraction)})", :class => :count, :style => "height:#{[ h.hours.to_f * 10, 100 ].min}%", :title => "#{d} (#{pluralize h.hours, "hour"})")
  end
  
  def describe_date_range(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.reverse_merge :include_day => true
    dates = args.collect(&:to_date).sort
    start_date, end_date = dates.first, dates.last
    if start_date == end_date
      start_date.strftime(options[:include_day] ? "#{start_date.day} %B, %Y" : "%B %Y")
    elsif start_date.month == end_date.month
      start_date.strftime(options[:include_day] ? "#{start_date.day}–#{end_date.day} %B, %Y" : "%B %Y")
    elsif start_date.year == end_date.year
      options[:include_day] ? start_date.strftime("#{start_date.day} %B") + end_date.strftime(" – #{end_date.day} %B, %Y") : start_date.strftime("%B") + end_date.strftime(" – %B, %Y")
    else
      options[:include_day] ? start_date.strftime("#{start_date.day} %B, %Y") + end_date.strftime(" – #{end_date.day} %B, %Y") : start_date.strftime("%B, %Y") + end_date.strftime(" – #{end_date.day} %B, %Y")
    end
  end
end
