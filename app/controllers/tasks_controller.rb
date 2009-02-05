class TasksController < ApplicationController
  before_filter :get_task_list
  before_filter :clean_assignments, :only => [ :create, :update ]
  
  def index
    
  end
  
  def show
    @task = Task.find params[:id], :include => { :assignments => :users }
  end
  
  def new
    @task = Task.new :task_list => @task_list
  end
  
  def create
    # TODO error checking
    @task = @task_list.tasks.build params[:task]
    @task.save
    redirect_to @task.project
  end
  
  def edit
    @task = Task.find params[:id], :include => { :assignments => :users }
  end
  
  def update
    # TODO error checking
    @task = Task.find params[:id], :include => { :assignments => :users }
    @task.update_attributes params[:task]
    redirect_to @task.project
  end

protected
  def get_task_list
    @task_list = params[:list_id] && TaskList.find(params[:list_id])
  end
  
  def clean_assignments
    params[:task][:assignments_attributes].reject! { |k, v| k =~ /^new_/ && v["_delete"] == "1" } unless params[:task].blank? || params[:task][:assignments_attributes].blank?
    logger.info params[:task][:assignments_attributes].inspect
  end
end
