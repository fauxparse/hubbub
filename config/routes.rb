ActionController::Routing::Routes.draw do |map|
  map.resources :companies, :shallow => true do |company|
    company.resources :users
  end

  map.resource :settings, :controller => "users"
  map.resources :users
  
  map.login "/login", :controller => "user_sessions", :action => "new"
  map.logout "/logout", :controller => "user_sessions", :action => "destroy"
  
  map.resource :user_session
  map.resource :dashboard
  
  map.root :controller => "accounts", :action => "index", :conditions => { :subdomain => false }
  map.root :controller => "dashboards", :action => "index", :conditions => { :subdomain => true }
end
