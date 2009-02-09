class TimeController < ApplicationController
  def index
    if request.xhr?
      # TODO: scope to account
      @task = params[:task_id] && Task.find(params[:task_id], :include => :assignments)
      # TODO: visibility permissions
      @user = params[:user_id] ? User.find_by_login(params[:user_id]) : current_user
      @assignment = @task && @user && @task.assignments.detect { |a| a.user == @user }
      @times = TimeSlice.for_user(@user).for_task(@task).reverse_order.all(:include => [ :user, :activity ])
      # TODO: proper credentials
      # TODO: only users assigned to the task

      @users = @user && @user.admin? ? current_user.company.users : [ current_user ]

      render :action => "popup"
    end
  end
  
  def create
    @user = params[:user_id] && User.find_by_login(params[:user_id])
    @time_slice = TimeSlice.create params[:time_slice]
    @task = @time_slice.task :include => :assignments
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    @time_slice = TimeSlice.find params[:id], :include => :activity
    @task = @time_slice.task :include => :assignments
    @time_slice.destroy
    respond_to do |format|
      format.js
    end
  end
end
