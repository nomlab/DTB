Rails.application.routes.draw do
  root to: "welcome#index"

  get 'agenda/calendar'
  get 'agenda/tree'

  get "missions/organize"
  put "missions/update_parent_id/:id(.:format)", :to => "missions#update_parent_id"
  resources :missions

  put "states/update_color/:id", :to => "states#update_color"
  put "states/update_default/:id", :to => "states#update_default"
  resources :states

  get "tasks/organize"
  put "tasks/update_mission_id/:id(.:format)", :to => "tasks#update_mission_id"
  put "tasks/update_state/:id", :to => "tasks#update_state"
  resources :tasks

  get "time_entries/organize"
  get "time_entries/stop"
  put "time_entries/sync"
  put "time_entries/update_task_id/:id(.:format)", :to => "time_entries#update_task_id"
  resources :time_entries

  resources :unified_histories
  # For STL, route file_histories/ and web_histories/ to unified_histories/
  resources :file_histories, controller: :unified_histories
  resources :web_histories, controller: :unified_histories

  get ':controller(/:action(/:id(.:format)))'
  post ':controller(/:action(/:id(.:format)))'
end
