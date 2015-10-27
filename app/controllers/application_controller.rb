class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :set_root_missions
  before_filter :set_inbox_tasks

  private
  def set_root_missions
    @root_missions = Mission.roots
  end

  def set_inbox_tasks
    @inbox_tasks = Task.unorganized
  end
end
