class TimeEntry < ActiveRecord::Base
  belongs_to :task

  def self.current
    return @@current_time_entry
  end

  def self.current=(time_entry)
    return @@current_time_entry = time_entry
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

  def duration
    return {"start_time" => start_time, "end_time" => end_time}
  end

  def unified_histories
    return UnifiedHistory.where(["start_time >= ? and start_time <= ? or end_time >= ? and end_time <= ?",
                                 start_time, end_time, start_time, end_time])
  end

  def file_histories
    return unified_histories.select{|uh| uh.history_type == "file_history"}
  end

  def web_histories
    return unified_histories.select{|uh| uh.class == "web_history"}
  end

  def restore
    unified_histories.map(&:restore)
  end
end
