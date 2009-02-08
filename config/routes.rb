ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => { :subdomain => true } do |account|
    account.resources :companies, :shallow => true do |company|
      company.resources :people, :controller => "users"
      company.resources :projects do |project|
        project.resources :lists, :controller => "task_lists" do |list|
          list.resources :tasks do |task|
            task.resources :assignments
            task.resources :time, :singular => "time_slice"
          end
        end
      end
    end
    map.resources :tasks
    map.resources :projects
    map.resources :time, :singular => "time_slice"

    account.resource :settings, :controller => "users"
    account.resources :people, :controller => "users"
    account.resources :time, :singular => "time_slice"
  
    account.login "/login", :controller => "user_sessions", :action => "new"
    account.logout "/logout", :controller => "user_sessions", :action => "destroy"
  
    account.resource :user_session
    account.resource :dashboard
    account.root :controller => "dashboards", :action => "show"
  end
  
  map.root :controller => "accounts", :action => "index", :conditions => { :subdomain => false }
end
