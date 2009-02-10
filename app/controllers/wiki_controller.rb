class WikiController < ApplicationController
  before_filter :internal_login_required_for_wiki
  before_filter :get_wiki_page_from_full_path, :only => [ :show, :edit, :update, :destroy ]

  # TODO: caching for category list, wiki pages etc

  def index
    params[:id] = "Home"
    get_wiki_page_from_full_path
    show
  end
  
  def show
    if @wiki_page.new_record?
      @mode = :new
      flash.now[:notice] = "No page called #{@wiki_page} exists. If you like, you can create it below."
    elsif params[:revision] && params[:revision] != @wiki_page.latest_revision
      flash.now[:notice] = "You are viewing an older version of this page. <a href=\"#{full_wiki_page_path(@wiki_page)}\">Click here</a> for the latest version."
      @wiki_page = @wiki_page.at params[:revision]
    end
    render :action => @mode
  end
  
  def create
    @wiki_page = current_agency.wiki_pages.build params[:wiki_page].merge(:author_id => current_user.id)
    if @wiki_page.save
      flash[:notice] = "Page created successfully"
      redirect_to "/wiki#{@wiki_page.to_param}"
    else
      render :action => "new"
    end
  end
  
  def edit
  end
  
  def update
    if @wiki_page.update_attributes params[:wiki_page].merge(:author_id => current_user.id)
      flash[:notice] = "Page created successfully"
      redirect_to "/wiki#{@wiki_page.to_param}"
    else
      @wiki_page.title = @wiki_page.title_was if @wiki_page.errors.on(:title).any?
      render :action => "edit"
    end
  end
  
  def history
    @wiki_page = WikiPage.find(params[:id])
    render :partial => "history"
  end
  
  def search
    unless (@query = params[:q]).blank?
      @search = WikiPage.search @query.split
      @results = @search.all
    end
  end
  
protected
  def internal_login_required_for_wiki
    unless current_user.agency_user?
      flash[:notice] = "Sorry, the wiki is currently for internal use only"
      redirect_to root_url
      return false
    end
  end
  
  def get_wiki_page_from_full_path
    path, @mode = Array(params[:id]) * "/", :show
    path, @mode = File.dirname(path), :edit if path.ends_with? "/edit"

    @wiki_page = current_agency.wiki_pages.find_or_initialize_by_title path.gsub("+", " ")
  end
end
