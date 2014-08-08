class Task < ActiveRecord::Base
  has_many :time_entries
  belongs_to :mission

  def self.current
    @@current_task
  end

  def self.current=(task)
    @@current_task = task
  end

  def start(options)
    # Project = self.name
    return TimeEntry.current = TOGGL_API_CLIENT.start_time_entry(options)
  end

  def stop
    return TOGGL_API_CLIENT.stop_time_entry(TimeEntry.current.toggl_time_entry_id)
  end

  def unified_histories
    return time_entries.map(&:unified_histories).flatten
  end

  def file_histories
    return time_entries.map(&:file_histories).flatten
  end

  def web_histories
    return time_entries.map(&:web_histories).flatten
  end

  def restore
    unified_histories.map(&:restore)
  end

  def finish
    self.update_attributes :status => true
  end

  def finished?
    return self.status
  end
end
