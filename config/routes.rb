DesktopBookmark::Application.routes.draw do
  root :to => "desktop_bookmark#index"

  scope "desktop_bookmark" do
    root  :to => "desktop_bookmark#index"
    
    # desktop_bookmark/work/select
    post "work/select", :to => "works#select"
    # 
    match "start", :to => "desktop_bookmark#start"
    match "stop",  :to => "desktop_bookmark#stop"

    # old interface for evaluation
    match "task/list", :to => "tasks#list"
    match "bookmark/list", :to => "bookmarks#list"
    resources :work, :controller => :works do
      #desktop_bookmark/work/:work_id/destroy
      get "destroy", :to => "works#destroy"
      post "finish", :to => "works#finish"

      resources :task, :controller => :tasks do
        #desktop_bookmark/work/:work_id/task/:task_id/destroy
        get "destroy", :to => "tasks#destroy"
        post "finish", :to => "tasks#finish"
        # route for ajax request to start/stop a task 
        # desktop_bookmark/work/:work_id/task/:task_id/[srart|stop]
#        post "start", :to => "tasks#start"
#        post "stop", :to => "tasks#stop"

        resources :bookmark, :controller => :bookmarks do
          get "destroy", :to => "bookmarks#destroy"
          
          match "file_history/edit", :to => "file_histories#edit"
          resources :file_history, :controller => :file_histories, :except => ["destroy", "edit"]
          delete "file_history/destroy", :to => "file_histories#destroy"
          match 'file_history/:id/link', :controller => :file_histories, :action => :link
          
          match "web_history/edit", :to => "web_histories#edit"
          resources :web_history, :controller => :web_histories, :except => ["destroy", "edit"]
          delete "web_history/destroy", :to => "web_histories#destroy"
        end
      end
    end
  end
  match "desktop_bookmark/:action", :controller => "desktop_bookmark"
end
