class Task < ActiveRecord::Base
  has_many :time_entries
  belongs_to :mission
  belongs_to :state
  default_scope { order(created_at: :desc) }

  def self.current
    @current_task
  end

  def self.current=(task)
    @current_task = task
  end

  def durations
    return time_entries.map(&:duration)
  end

  def duration
    return durations.inject{|d1, d2| d1.merge d2}
  end

  def unified_histories
    return [] if duration.nil?
    candidates = UnifiedHistory.where(["start_time >= ? and start_time <= ? or end_time >= ? and end_time <= ?",
                                       duration.start_time, duration.end_time,
                                       duration.start_time, duration.end_time])
    return candidates.select do |c|
      durations.select{|d| d.overlap?(c) }.present?
    end
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

  def finish
    self.update_attributes :status => true
  end

  def finished?
    return self.status
  end

  def to_event
    return {
      id:        id,
      title:     name,
      start:     duration.start_time,
      end:       duration.end_time,
      type:      "task",
      color:     "#FAD165",
      textColor: "#000000"
    }
  end
end
