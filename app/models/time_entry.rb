class TimeEntry < ActiveRecord::Base
  belongs_to :task
  default_scope { order(created_at: :desc) }

  def self.current
    @current_time_entry
  end

  def self.current=(time_entry)
    @current_time_entry = time_entry
  end

  def self.import
    TOGGL_API_CLIENT.get_time_entries(Time.parse(base.me["created_at"]), Time.now).each do |te|
      if TimeEntry.where(["toggl_time_entry_id = ?", te["id"]]).blank?
        time_entry = TimeEntry.new({name: te["description"], start_time: Time.parse(te["start"]),
                                     end_time: Time.parse(te["start"]) + te["duration"],
                                     toggl_time_entry_id: te["id"],
                                     running_status: te["duration"] >= 0 ? false : true})
      else
        time_entry = TimeEntry.where(["toggl_time_entry_id = ?", te["id"]]).first
        time_entry.update({name: te["description"], start_time: Time.parse(te["start"]),
                                     end_time: Time.parse(te["start"]) + te["duration"],
                                     running_status: te["duration"] >= 0 ? false : true})
      end
      time_entry.save
    end
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
