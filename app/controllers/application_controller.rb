class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :set_root_missions

  private
  def set_root_missions
    @root_missions = Mission.roots
    @inbox_tasks = Task.unorganized
  end
end
