ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => { :subdomain => true } do |account|
    account.resources :companies, :shallow => true do |company|
      company.resources :users
      company.resources :projects do |project|
        project.resources :task_lists
      end
    end

    account.resource :settings, :controller => "users"
    account.resources :users
  
    account.login "/login", :controller => "user_sessions", :action => "new"
    account.logout "/logout", :controller => "user_sessions", :action => "destroy"
  
    account.resource :user_session
    account.resource :dashboard
    account.root :controller => "dashboards", :action => "show"
  end
  
  map.root :controller => "accounts", :action => "index", :conditions => { :subdomain => false }
end
