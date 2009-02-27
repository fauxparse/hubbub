ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => { :subdomain => true } do |account|
    account.resources :lists, :controller => "task_lists", :collection => { :reorder => :put }
    account.resources :tasks, :member => { :complete => :put }, :collection => { :reorder => :put }
    account.resources :companies, :shallow => true do |company|
      company.resources :people, :controller => "users"
      company.resources :projects do |project|
        project.resources :lists, :controller => "task_lists" do |list|
          list.resources :tasks do |task|
            task.resources :assignments
            task.resources :time, :singular => "time_slice"
            task.resources :blockages
          end
        end
      end
    end
    account.resources :projects
    account.resources :time, :singular => "time_slice"

    account.resource :settings, :controller => "users"
    account.resources :people, :controller => "users"
    account.resources :time, :singular => "time_slice"
    account.resources :wiki, :singular => "wiki_page", :member => { :history => :get }, :collection => { :search => :get }
    account.edit_full_wiki_page "/wiki/*id/edit", :controller => "wiki", :action => "edit", :format => :html, :conditions => { :method => :get }
    account.update_full_wiki_page "/wiki/*id", :controller => "wiki", :action => "update", :format => :html, :conditions => { :method => :put }
    account.full_wiki_page "/wiki/*id", :controller => "wiki", :action => "show", :format => :html, :conditions => { :method => :get }
  
    account.login "/login", :controller => "user_sessions", :action => "new"
    account.logout "/logout", :controller => "user_sessions", :action => "destroy"
  
    account.resource :user_session
    account.resource :dashboard
    account.root :controller => "dashboards", :action => "show"
  end
  
  map.root :controller => "accounts", :action => "index", :conditions => { :subdomain => false }
end
