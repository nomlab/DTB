class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :selector_setup

  def selector_setup
    @selected_work = Work.current || Work.find_by_id(session[:work_id]) rescue nil
    @selected_tasks = @selected_work.tasks rescue []
  end
end
