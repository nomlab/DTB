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

  def durations_of_day(date)
    date_duration = Duration.new(date.to_time, date.tomorrow.to_time)
    durations.map{|duration| duration.slice(date_duration)}.compact
  end

  def work_time_length
    durations.map(&:length).reduce(0, :+)
  end

  def work_time_length_of_day(date)
    durations_of_day(date).map(&:length).reduce(0, :+)
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

  def integrated_histories
    @grouped_histories = unified_histories.group_by{|uh| uh.path}
    @grouped_histories.map{|path, uhs| IntegratedHistory.new(uhs)}
  end

  def to_occurrences
    occurrences = durations.map do |d|
      {
        id:        id,
        title:     name,
        start:     d.start_time.iso8601,
        end:       d.end_time.iso8601,
        type:      "task",
        className: "task-occurrence"
      }
    end
  end
end
