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
