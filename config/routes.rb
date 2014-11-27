Rails.application.routes.draw do
  root to: "welcome#index"

  get 'agenda/calendar'
  get 'agenda/tree'

  get "unified_histories/organize"
  put "unified_histories/update_usage/:id(.:format)", :to => "unified_histories#update_usage"
  resources :unified_histories

  get "time_entries/organize"
  get "time_entries/stop"
  put "time_entries/sync"
  put "time_entries/update_task_id/:id(.:format)", :to => "time_entries#update_task_id"
  resources :time_entries

  get "tasks/organize"
  put "tasks/update_mission_id/:id(.:format)", :to => "tasks#update_mission_id"
  resources :tasks

  resources :missions

  get ':controller(/:action(/:id(.:format)))'
  post ':controller(/:action(/:id(.:format)))'
end
