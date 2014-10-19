class TimeEntry < ActiveRecord::Base
  belongs_to :task
  default_scope { order(created_at: :desc) }

  def self.current
    @current_time_entry
  end

  def self.current=(time_entry)
    @current_time_entry = time_entry
  end

  def self.start(options, task_id)
    response = TOGGL_API_CLIENT.start_time_entry(options)
    return TimeEntry.current = TimeEntry.create(:name => response.description,
                                                :start_time => Time.parse(response.start).localtime("+09:00"),
                                                :task_id => task_id,
                                                :toggl_time_entry_id => response.id)
  end

  def self.stop
    time_entry = TimeEntry.current
    response = TOGGL_API_CLIENT.stop_time_entry(TimeEntry.current.toggl_time_entry_id)
    TimeEntry.current = nil
    time_entry.end_time = Time.parse(response.stop).localtime("+09:00")
    time_entry.save
  end

  def self.partial_sync(start_date, end_date)
    toggl_time_entries = TOGGL_API_CLIENT.get_time_entries(start_date, end_date)
    toggl_time_entries.each do |toggl_time_entry|
      dtb_time_entry = TimeEntry.find_by(toggl_time_entry_id: toggl_time_entry.id)
      if dtb_time_entry
        dtb_time_entry.sync
      else
        TimeEntry.create(
                         name: toggl_time_entry.description,
                         start_time: toggl_time_entry.start,
                         end_time: toggl_time_entry.stop,
                         toggl_time_entry_id: toggl_time_entry.id
                         )
      end
    end
  end

  def self.completely_sync
    TimeEntry.partial_sync(Time.new("2006-01-01"), nil)
  end

  def duration
    return Duration.new(start_time, end_time)
  end

  def unified_histories
    return UnifiedHistory.where(["start_time >= ? and start_time <= ? or end_time >= ? and end_time <= ?",
                                 start_time, end_time, start_time, end_time])
  end

  def file_histories
    return unified_histories.select{|uh| uh.history_type == "file_history"}
  end

  def web_histories
    return unified_histories.select{|uh| uh.history_type == "web_history"}
  end

  def restore
    unified_histories.map(&:restore)
  end

  def sync
    toggl_time_entry = TOGGL_API_CLIENT.get_time_entry(toggl_time_entry_id)
    if toggl_time_entry.nil?
      destroy
    else
      if Time.parse(toggl_time_entry.at) > updated_at
        self.name = toggl_time_entry.description
        self.start_time = toggl_time_entry.start
        self.end_time = toggl_time_entry.stop
        save
      else
        options = {
          description: name,
          start:       start_time.iso8601,
          stop:        end_time.iso8601,
          duration:    duration.to_seconds
        }
        TOGGL_API_CLIENT.update_time_entry(toggl_time_entry_id, options)
      end
    end
  end

  def to_event
    return {
      id:        id,
      title:     name,
      start:     duration.start_time,
      end:       duration.end_time,
      type:      "time_entry",
      color:     "#7BD148",
      textColor: "#000000"
    }
  end
end
