class TasksController < ApplicationController
  before_filter :get_task_list
  before_filter :clean_assignments, :only => [ :create, :update ]
  
  def index
    
  end
  
  def show
    @task = Task.find params[:id], :include => { :assignments => :user }
  end
  
  def new
    @task = Task.new :task_list => @task_list
  end
  
  def create
    @task = @task_list.tasks.build params[:task]
    respond_to do |format|
      if @task.save
        format.js
        format.html { redirect_to @task.project }
      else
        format.js
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @task = Task.find params[:id], :include => { :assignments => :user }
  end
  
  def update
    @task = Task.find params[:id], :include => { :assignments => :user }
    respond_to do |format|
      if @task.update_attributes params[:task]
        format.js
        format.html { redirect_to @task.project }
      else
        format.js
        format.html { render :action => "new" }
      end
    end
  end

protected
  def get_task_list
    @task_list = params[:list_id] && TaskList.find(params[:list_id])
  end
  
  def clean_assignments
    params[:task][:assignments_attributes].reject! { |k, v| k =~ /^new_/ && v["_delete"] == "1" } unless params[:task].blank? || params[:task][:assignments_attributes].blank?
  end
end
