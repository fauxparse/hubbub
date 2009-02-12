module TimeHelper
  def graph_recent_activity(times, end_date = nil)
    end_date ||= Date.today
    start_date = end_date - 1.month
    returning "" do |result|
      result << "<div class=\"graph\">"
      result << content_tag(:h2, describe_date_range(start_date, end_date))
      result << "<ul class=\"timeline\">"
      dates = (start_date..end_date).to_a
      hours = dates.collect { |d| times.select { |t| t.date == d }.sum(ElapsedTime.hours(0), &:elapsed_time) }
      hours_per_day = dates.zip hours
      max_hours = [ hours.max.to_i, 8 * 60 ].max
      
      hours_per_day.each do |d, h|
        result << content_tag(:li, link_to(content_tag(:span, d.day, :class => :label) + content_tag(:span, "(#{h.to_s(:fraction)})", :class => :count, :style => "height:#{h.to_i * 100 / max_hours}%"), "#", :title => "#{d} (#{pluralize h.to_s(:fraction), "hour"})"), :class => ((d.wday + 1) % 7 < 2 ? "weekend" : "weekday"))
      end
      result << "</ul>"
      result << clear_floats
      result << "</div>"
    end
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
  
  def user_selector(selected = nil, options = {})
    selected = selected.id if selected.is_a? User
    result = ""
    result << content_tag(:optgroup, content_tag(:option, "(Anybody)", :value => nil, :selected => selected.nil?))
    result << content_tag(:optgroup, content_tag(:option, "#{current_user} (Me)", :value => current_user.id, :selected => (selected == current_user.id)))
    result << content_tag(:optgroup, options_for_select((current_agency.users - current_user).collect { |u| [ u.to_s, u.id ] }, selected))
    content_tag :select, result, options
  end
end
