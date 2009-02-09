# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SubdomainAccounts
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '762ca33d2866aba835d8db6d3e783487'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :current_company, :current_agency, :current_users
  
  before_filter :check_account_status
  before_filter :login_required
  
  layout :current_layout_name

protected
  def check_account_status
    #unless account_subdomain == default_account_subdomain
      # TODO: this is where we could check to see if the account is active as well (paid, etc...)
      redirect_to default_account_url if current_account.nil? 
    #end
  end

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    @current_user ||= (current_user_session && current_user_session.user)
  end
  
  def login_required
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def public_site?
    account_subdomain == default_account_subdomain
  end

  def current_layout_name
    public_site? ? 'public' : 'application'
  end

  def current_company
    @company ||= params[:company_id] ? Company.find_by_slug(params[:company_id]) : current_agency
  end
  
  def current_agency
    @agency ||= Company.find(current_account.agency_id)
  end
  
  def current_companies
    @companies ||= [ current_company, current_agency ].uniq
  end
  
  def current_users
    @users ||= current_companies.collect(&:users).flatten
  end
  
  def render(options = nil, extra_options = {}, &block)
    if request.xhr?
      (options ||= {})[:layout] ||= false
      super options, extra_options, &block
    else
      super
    end
  end
end
