class Task < ActiveRecord::Base
  has_many :time_entries
  belongs_to :mission
  belongs_to :state
  default_scope { includes(:state).order(created_at: :desc) }
  scope :unorganized, -> { where(mission_id: nil) }

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
    candidates = UnifiedHistory.in(duration)
    return candidates.select do |c|
      durations.select{|d| d.overlap?(c) }.present?
    end
  end

  def file_histories
    return unified_histories.select{|h| h.type == "FileHistory" }
  end

  def web_histories
    return unified_histories.select{|h| h.type == "WebHistory" }
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
      start:     deadline,
      type:      "task",
      color:     "#FAD165",
      textColor: "#000000"
    }
  end
end
