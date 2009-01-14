ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users
  
  map.login "/login", :controller => "user_sessions", :action => "new"
  map.login "/logout", :controller => "user_sessions", :action => "destroy"
  
  map.resource :user_session
  map.root :controller => "user_sessions", :action => "new"
end
