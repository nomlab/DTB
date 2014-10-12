DTB::Application.routes.draw do
  get "unified_histories/organize", :to => "unified_histories#organize"
  put "unified_histories/update_usage/:id(.:format)", :to => "unified_histories#update_usage"
  resources :unified_histories

  get "time_entries/stop", :to => "time_entries#stop"
  resources :time_entries

  resources :tasks

  get "missions/tree", :to => "missions#tree"
  get "missions/calendar", :to => "missions#calendar"
  resources :missions

  root to: "welcome#index"

  get ':controller(/:action(/:id(.:format)))'
  post ':controller(/:action(/:id(.:format)))'
end
