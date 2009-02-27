class BlockagesController < ApplicationController
  before_filter :get_task, :only => [ :index, :new, :create ]
  
  def new
    @blockage = @task.blockages.build
  end
  
  def create
    @blockage = @task.blockages.build((params[:blockage] || {}).reverse_merge(:user => current_user))
    respond_to do |format|
      @blockage.save
      format.js
    end
  end
  
  def destroy
    @blockage = Blockage.find params[:id]
    @blockage.destroy
    respond_to do |format|
      format.js
    end
  end
  
protected
  def get_task
    @task = Task.find params[:task_id]
  end
end
