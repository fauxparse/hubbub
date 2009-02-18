module TasksHelper
  def task_assignment_fields_for(form, users)
    task = form.object
    assignments = users.sort.collect { |user| task.assignments.detect { |t| t.user == user } || task.assignments.build(:user => user) }
    returning "" do |result|
      form.fields_for :assignments do |fields|
        assignment = fields.object
        id = assignment.new_record? ? "new_#{assignment.user.id}" : assignment.id.to_s
        result << "<dd>" + fields.check_box(:_delete, { :checked => assignment.new_record? ? false : true }, "0", "1") + " " + fields.label(:_delete, assignment.user) + fields.hidden_field(:user_id) + "</dd>"
      end
    end
  end
  
  def assignment_user_selector(name, users, selected, current, options = {})
    option_tags = (b = options.delete(:include_blank)) ? "<option value=\"\">#{b === true ? 'Select user...' : b}</option>" : ""
    option_tags += options_for_select([[ "#{current.display_name} (me)", current.id ]], selected) + grouped_options_for_select(users.collect(&:company).uniq.sort.collect { |c| [ c, (users - [ current ]).select { |u| u.company_id == c.id }.collect { |u| [ u.display_name, u.id ] }.sort_by(&:first) ] }, selected)
    select_tag name, option_tags, options
  end
  
  def task_users(task)
    result = if task.anybody?
      # TODO: make 'anybody' link show whether time has been recorded
      link_to "Anybody", task_time_path(task), :rel => :facebox
    else
      task.unassigned? ? link_to("(unassigned)", edit_task_path(task, :format => :js), :rel => :facebox, :class => :unassigned) : task.assignments.sort.collect { |a| assignment_link(a) }.to_sentence
    end
    content_tag :span, result, :class => :users
  end
  
  def task_classes(task)
    classes = %w(task)
    classes << "overdue"    if task.due_on && (task.completed? ? (task.due_on < task.completed_on) : (task.due_on <= Date.today))
    classes << "blocked"    if task.blocked?
    classes << "anybody"    if task.anybody?
    classes << "unassigned" if task.unassigned?
    classes << (task.completed? ? "completed" : "open")
    classes += task.assignments.collect { |a| "user_#{a.user_id}"}
    classes << task.current.state.name
    classes * " "
  end
  
  def assignment_link(assignment)
    classes = %w(assignment)
    classes << "blocked" if assignment.blocked?
    classes << "completed" if assignment.completed?
    classes << "started" if assignment.total_minutes > 0
    link_to assignment, task_time_path(assignment.task, :user_id => assignment.user || current_user), :rel => :facebox, :title => "#{assignment.recorded_time} hours", :class => classes * " "
  end
  
  def recorded_time_for(activity)
    result = ""
    if activity.respond_to? :user
      result << "<span class=\"icon\"></span>"
      result << "<span class=\"user\">"
      result << "<strong>#{activity.user}</strong> " unless activity.user.blank?
      result << "(#{activity.role})" unless activity.role.blank?
      result << "</span>"
    end
    result << content_tag(:span, activity.recorded_time.to_s(:fraction), :class => "recorded")
		result << " of " + content_tag(:span, activity.estimated_time.to_s(:fraction), :class => "budget") if activity.estimated?
		result << " hours"
		result << " <small>(completed)</small>" if activity.completed?
		classes = []
		classes << "blocked" if activity.respond_to?(:blocked?) && activity.blocked?
		classes << "completed" if activity.completed?
		if activity.respond_to?(:user) && activity.user
  		link_to result, task_time_path(activity.task), :rel => :facebox, :class => "#{activity.class.name.underscore}-recorded-time #{dom_id(activity.user)} #{classes.join(' ')}", :id => dom_id(activity, :recorded_time)
		else
  		content_tag :span, result, :class => "#{activity.class.name.underscore}-recorded-time #{classes.join(' ')}", :id => dom_id(activity, :recorded_time)
		end
  end
end
