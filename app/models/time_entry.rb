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
    # For cooperating with Toggl
    response = TOGGL_API_CLIENT.start_time_entry(options)
    return TimeEntry.current = TimeEntry.create(:name => response.description,
                                                :start_time => Time.parse(response.start).localtime("+09:00"),
                                                :task_id => task_id,
                                                :toggl_time_entry_id => response.id)

    # For stand alone
    # return TimeEntry.current = TimeEntry.create(:name => options[:description],
    #                                             :start_time => Time.current,
    #                                             :task_id => task_id
    #                                             )
  end

  def self.stop
    # For cooperating with Toggl
    response = TOGGL_API_CLIENT.stop_time_entry(TimeEntry.current.toggl_time_entry_id)

    time_entry = TimeEntry.current
    TimeEntry.current = nil
    time_entry.end_time = Time.current
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
    # Toggl API does not provide API to get all time entries
    # but provide API to get time entries started in a specific time range.
    # Service of Toggl is started at 2006.
    # So, in order to get all time entries, "2006-01-01" is used.
    TimeEntry.partial_sync(Time.new("2006-01-01"), nil)
  end

  def duration
    return Duration.new(start_time, end_time)
  end

  def unified_histories
    return UnifiedHistory.in(duration)
  end

  def file_histories
    return unified_histories.file_histories
  end

  def web_histories
    return unified_histories.web_histories
  end

  def restore
    unified_histories.map(&:restore)
  end

  def sync
    toggl_time_entry = TOGGL_API_CLIENT.get_time_entry(toggl_time_entry_id)
    if toggl_time_entry.server_deleted_at
      self.destroy
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
end
