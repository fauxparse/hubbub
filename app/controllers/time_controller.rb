class TimeController < ApplicationController
  def index
    # TODO: scope to account
    @task = params[:task_id] && Task.find(params[:task_id], :include => :assignments)
    # TODO: visibility permissions
    @user = params[:user_id] ? User.find_by_login(params[:user_id]) : current_user
    @assignment = @task && @user && @task.assignments.detect { |a| a.user == @user }
    
    logger.info Date.today.to_formatted_s(:long)

    if request.xhr?
      @times = TimeSlice.for_user(@user).for_task(@task).reverse_order.all(:include => [ :user, :task ])
      # TODO: proper credentials
      @users = @user && @user.admin? ? (@task ? @task.users : current_user.company.users) : [ current_user ]
      render :action => "popup"
    else
      @report = current_agency.reports.build(params[:report])
      
      
      
      @start_date, @end_date = [ :from, :until ].collect { |p| (params[p] || params[:date]) && (params[p] || params[:date]).to_date }
      @times = TimeSlice.for_user(@user).for_task(@task).from_date(@start_date).until_date(@end_date).all(:include => [ :user ])
      
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
