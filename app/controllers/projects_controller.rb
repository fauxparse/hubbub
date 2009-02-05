class ProjectsController < ApplicationController
  before_filter :get_project, :except => [ :index, :new, :create ]
  helper_method :scope, :viewing_multiple_companies?
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = scope.all :include => :company

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = scope.new :company_id => current_company.id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = scope.new params[:project].reverse_merge(:company_id => current_company.id)
    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to(@project) }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = "Project updated. (<a href=\"#{project_path(@project)}\">Return to project view</a>)"
        format.html { redirect_to edit_project_path(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
  
protected
  def scope
    params[:company_id].blank? ? (current_user.company.is_a?(Agency) ? Project.for_agency(current_user.company) : current_user.company.projects) : current_company.projects
  end
  
  def viewing_multiple_companies?
    params[:company_id].blank? && current_user.company.is_a?(Agency)
  end
  
  def get_project
    @project ||= scope.find(params[:id].to_i, :include => :company) unless params[:id].blank?
  end
end
