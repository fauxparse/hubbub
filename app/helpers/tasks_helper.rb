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
    classes = returning %w(task) do |c|
      c << "overdue" if task.due_on && task.due_on <= Date.today
      c << "blocked" if task.blocked?
      c << task.current.state.name
    end
    classes * " "
  end
  
  def assignment_link(assignment)
    classes = %w(assignment)
    classes << "blocked" if assignment.blocked?
    classes << "completed" if assignment.completed?
    classes << "started" if assignment.total_minutes > 0
    link_to assignment, task_time_path(assignment.task, :user_id => assignment.user || current_user), :rel => :facebox, :title => "#{assignment.elapsed_time} hours", :class => classes * " "
  end
end
