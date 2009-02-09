class WikiController < ApplicationController
  before_filter :internal_login_required_for_wiki
  before_filter :get_wiki_page_from_full_path, :only => [ :show, :edit, :update, :destroy ]

  def index
    params[:id] = "Home"
    get_wiki_page_from_full_path
    show
  end
  
  def show
    if @wiki_page.new_record?
      @mode = :new
      flash.now[:notice] = "No page called #{@wiki_page} exists. If you like, you can create it below."
    end
    render :action => @mode
  end
  
  def create
    @wiki_page = current_agency.wiki_pages.build params[:wiki_page].merge(:author_id => current_user.id)
    if @wiki_page.save
      flash[:notice] = "Page created successfully"
      redirect_to full_wiki_page_path @wiki_page
    else
      render :action => "new"
    end
  end
  
  def edit
  end
  
  def update
    if @wiki_page.update_attributes params[:wiki_page]
      flash[:notice] = "Page created successfully"
      redirect_to full_wiki_page_path @wiki_page
    else
      @wiki_page.title = @wiki_page.title_was if @wiki_page.errors.on(:title).any?
      render :action => "edit"
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
