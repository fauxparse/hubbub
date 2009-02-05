# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tabs(tabs)
    specials = { "people" => "users" }
    content_tag :ul, tabs.reverse.collect { |tab| content_tag :li, link_to(Array(tab).first.humanize, send(:"#{Array(tab).last.underscore}_path"), :class => "#{:active if [Array(tab).last.underscore, specials[Array(tab).last.underscore]].include?(controller.controller_name)}") }.join, :id => "tabs"
  end
end
