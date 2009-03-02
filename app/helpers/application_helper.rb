# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tabs(tabs, options = {})
    options[:aliases] ||= {}
    tabs.unshift %w(home root) unless options[:home] == false
    content_tag :ul, tabs.reverse.collect { |tab| title, dest = Array(tab).first.humanize, Array(tab).last.underscore; content_tag :li, link_to(title, send(:"#{dest}_path"), :class => "#{:active if [dest, options[:aliases][dest]].flatten.include?(controller.controller_name)}") }.join, :id => "tabs"
  end
  
  def clear_floats
    content_tag :div, "", :class => :cleaner
  end
  
  def facebox_dialog_buttons(buttons)
    content_tag :ol, content_tag(:li, buttons.collect { |b| button_to_function b.first.humanize, b.last, :class => "#{b.first} button" }, :class => :buttons), :class => :form
  end
  
  def facebox_close_button
    facebox_dialog_buttons [[ "Close", "$.facebox.close()" ]]
  end
  
  def rolodex(items, options = {})
    key_method = options[:key] || lambda { |item| item.to_s.upcase.first }
    weight_method = options[:weight] || lambda { |item| 1 }
    max_groups = options[:groups] || 5
    dict = options[:keys] ? Hash[*options[:keys].to_a.zip([])] : {}
    items.each do |item|
      key = key_method.is_a?(Proc) ? key_method.call(item) : item.send(key_method.to_sym)
      weight = weight_method.is_a?(Proc) ? weight_method.call(item) : item.send(weight_method.to_sym)
      dict[key] ||= { :weight => 0, :items => [] }
      dict[key][:weight] += weight
      dict[key][:items] << item
    end
    groups = (options[:keys] ? options[:keys].collect { |k| [ k, dict[k] || { :weight => 0, :items => [] } ] } : dict.to_a.sort_by(&:first)).collect { |k, v| [ Array(k), v ] }
    while groups.size > max_groups
      min, min_pos = nil, 0
      (0...groups.size - 1).each do |i|
        v = ((groups[i].last[:weight] || 0) + (groups[i + 1].last[:weight] || 0)) * (groups[i].first.size + groups[i+1].first.size)
        min, min_pos = v, i if min.nil? || v < min
      end
      groups[min_pos, 2] = [[groups[min_pos].first + groups[min_pos + 1].first, { :weight => min, :items => groups[min_pos].last[:items] + groups[min_pos + 1].last[:items] } ]]
    end
    groups.map! { |keys, dict| [keys, dict[:items]] }
    groups.each { |keys, items| yield [keys, items] } if block_given?
    groups
  end
  
  def auto_tabs(items, options_for_rolodex = {}, &block)
    groups = rolodex items, options_for_rolodex
    result = content_tag(:ul, groups.collect(&:first).collect { |k| content_tag(:li, link_to(k.size > 1 ? "#{k.first}&ndash;#{k.last}" : k.first.to_s, "#tab-#{k.join}"), :class => "tab-#{k.join}") }, :class => :tabs)
    result << groups.collect { |keys, items| content_tag :div, capture(keys, items, &block), :class => "pane tab-#{keys.join}", :style => "display: none" }.join
    result = content_tag(:div, result, :class => "tabbed")
    concat result
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
