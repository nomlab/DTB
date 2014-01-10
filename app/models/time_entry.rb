class TimeEntry < ActiveRecord::Base
  belongs_to :task

  def self.initialize_api_base
    toggl_api_token = YAML.load_file("local/toggl.yml")
    return Toggl::Base.new(toggl_api_token["toggl_api_token"])
  end

  def self.start(options)
    base = initialize_api_base
    return base.start_time_entry(options)
  end

  def self.running_time_entry
    return TimeEntry.where(["running_status = ?", true])
  end

  def stop
    base = TimeEntry.initialize_api_base
    return base.stop_time_entry(self.toggl_time_entry_id)
  end
end
