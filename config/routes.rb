DTB::Application.routes.draw do
  resources :unified_histories

  resources :time_entries

  resources :tasks

  get "missions/tree", :to => "missions#tree"
  resources :missions

  root to: "welcome#index"

  get ':controller(/:action(/:id(.:format)))'
  post ':controller(/:action(/:id(.:format)))'
end
