Rails.application.routes.draw do
  root to: "welcome#index"

  get 'agenda/calendar'
  get 'agenda/tree'

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

  get "unified_histories/organize"
  put "unified_histories/update_usage/:id(.:format)", :to => "unified_histories#update_usage"
  resources :unified_histories

  get ':controller(/:action(/:id(.:format)))'
  post ':controller(/:action(/:id(.:format)))'
end
