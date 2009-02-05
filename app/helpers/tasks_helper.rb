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
end
