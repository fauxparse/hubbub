# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tabs(tabs)
    content_tag :ul, tabs.reverse.collect { |tab| content_tag :li, link_to(Array(tab).first.humanize, send(:"#{Array(tab).last.underscore}_path"), :class => "#{:active if controller.controller_name == Array(tab).last.underscore}") }.join, :id => "tabs"
  end
end
