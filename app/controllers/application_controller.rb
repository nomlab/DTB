class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :set_root_missions

  private
  def set_root_missions
    @root_missions = Mission.all.select(&:root?)
    @inbox_tasks = Task.where(mission_id: nil)
  end
end
