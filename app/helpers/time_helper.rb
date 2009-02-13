module TimeHelper
  def graph_recent_activity(times, end_date = nil)
    end_date ||= Date.today
    start_date = end_date - 1.month
    returning "" do |result|
      result << "<div class=\"graph\">"
      result << content_tag(:h2, describe_date_range(start_date, end_date))
      result << "<ul class=\"timeline\">"
      dates = (start_date..end_date).to_a
      hours = dates.collect { |d| times.select { |t| t.date == d }.sum(Hour[0], &:recorded_time) }
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
  
  module Selectors
    def user_selector(users, current_user, options = {})
      select :user_id, [[ "#{current_user} (Me)", current_user.id ]] + (users - [current_user]).collect { |u| [ u.to_s, u.id ] }.sort_by(&:first), options.reverse_merge(:autocomplete => :off, :include_blank => "(anyone)", :class => "user-select")
    end
    
    def company_selector(companies, options = {})
      select :company_id, companies.collect { |c| [ c.to_s, c.id ] }.sort_by(&:first), options.reverse_merge(:autocomplete => :off, :include_blank => "(any company)", :class => "company-select")
    end

    def project_selector(projects, options = {})
      option_tags = @template.options_for_select([[ "(any project)", nil ]], object.project_id) + projects.group_by(&:company_id).collect { |company_id, projects|
        @template.options_for_select(projects.collect { |p| [p.to_s, p.id ] }, object.project_id).gsub "<option", "<option class=\"company_#{company_id}\""
      }.flatten.join
      @template.select_tag "#{object_name}[project_id]", option_tags, options.reverse_merge(:autocomplete => :off, :class => "project-select")
    end
  end
  
  def self.included(base)
    ActionView::Helpers::FormBuilder.send :include, Selectors
  end
end
