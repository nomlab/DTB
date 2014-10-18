class Task < ActiveRecord::Base
  has_many :time_entries
  belongs_to :mission
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

  def to_event
    return {
      id:        id,
      title:     name,
      start:     duration.start_time,
      end:       duration.end_time,
      type:      "task",
      color:     "#FFD5AC",
      textColor: "#000000"
    }
  end
end
