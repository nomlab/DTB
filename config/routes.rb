Rails.application.routes.draw do
  root to: 'agenda#tree'

  # Directs /agenda/* to AgendaController
  # (app/controllers/agenda_controller.rb)
  namespace :agenda do
    get 'calendar'
    get 'tree'
  end

  resources :missions do
    collection do
      get 'organize'
      post 'simple_create'
    end
  end

  resources :states do
    member do
      put 'update_color'
      put 'update_default'
    end
  end

  resources :tasks do
    collection do
      get 'organize'
      post 'simple_create'
    end

    member do
      get 'continue'
      put 'update_mission_id'
    end
  end

  resources :time_entries do
    collection do
      get 'organize'
      post 'start', to: 'time_entries#continue'
      post 'stop' # FIXME: post is unmatch
      post 'sync'
    end

    member do
      post 'continue'
      put 'update_task_id'
    end
  end

  resources :unified_histories do
    member do
      get 'restore'
    end
  end

  # For STI
  resources :file_histories, controller: :unified_histories
  resources :web_histories,  controller: :unified_histories
end
