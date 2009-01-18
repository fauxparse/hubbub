class TasksController < ApplicationController
  before_filter :get_task_list
  
  def new
    @task = Task.new :task_list => @task_list
  end

protected
  def get_task_list
    @task_list = params[:list_id] && TaskList.find(params[:list_id])
  end
end
