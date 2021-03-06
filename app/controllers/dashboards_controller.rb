class DashboardsController < ApplicationController
  def show
    @overdue_tasks = Task.for_user(current_user).overdue.all(:limit => 5)
    @recently_completed_tasks = Task.for_user(current_user).recently_completed.all(:limit => 5)
    @upcoming_tasks = Task.for_user(current_user).upcoming.all(:limit => 5)
    @blocking_tasks = Task.blocked_by(current_user).all(:order => "blockages.created_at ASC", :include => :blockages)
  end
end
