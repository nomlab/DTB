class ApplicationController < ActionController::Base
  protect_from_forgery
  
  prepend_before_filter :working_task_setup
  
  def working_task_setup
    if session[:task_id]
      Task.current = Task.find(session[:task_id]) rescue nil
    else
      Task.current = nil
    end
  end
end
