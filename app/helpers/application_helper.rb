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
end
