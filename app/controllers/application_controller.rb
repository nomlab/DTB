class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :set_root_missions
  before_action :set_inbox_tasks

  private

  def set_root_missions
    @root_missions = Mission.roots
  end

  def set_inbox_tasks
    @inbox_tasks = Task.unorganized
  end
end
