class TaskListsController < ApplicationController
  before_filter :get_task_list, :only => [ :edit, :update, :destroy ]
  helper_method :scope

  # GET /task_lists
  # GET /task_lists.xml
  def index
    @task_lists = scope.task_lists.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @task_lists }
    end
  end

  # GET /task_lists/1
  # GET /task_lists/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task_list }
    end
  end

  # GET /task_lists/new
  # GET /task_lists/new.xml
  def new
    @task_list = TaskList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task_list }
    end
  end

  # GET /task_lists/1/edit
  def edit
  end

  # POST /task_lists
  # POST /task_lists.xml
  def create
    @task_list = TaskList.new(params[:task_list].reverse_merge(:project_id => scope.id))

    respond_to do |format|
      if @task_list.save
        @task_list.move_to_top
        format.html do
          flash[:notice] = 'TaskList was successfully created.'
          redirect_to project_path(@task_list.project)
        end
        format.xml  { render :xml => @task_list, :status => :created, :location => @task_list }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task_list.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /task_lists/1
  # PUT /task_lists/1.xml
  def update
    respond_to do |format|
      if @task_list.update_attributes(params[:task_list])
        format.html do
          flash[:notice] = 'TaskList was successfully updated.'
          redirect_to list_path(@task_list)
        end
        format.xml  { head :ok }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task_list.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /task_lists/1
  # DELETE /task_lists/1.xml
  def destroy
    @task_list.destroy

    respond_to do |format|
      format.html { redirect_to project_lists_path(@task_list.project) }
      format.xml  { head :ok }
    end
  end
  
  def reorder
    TaskList.order = params[:task_list]
    
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

protected
  def scope
    @project ||= (params[:project_id].blank? ? current_account : current_account.projects.find(params[:project_id].to_i))
  end

  def get_task_list
    # TODO check permissions here
    @task_list ||= TaskList.find(params[:id].to_i, :include => :project)
  end
end
