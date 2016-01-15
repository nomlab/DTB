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
    time_entries.map(&:duration)
  end

  def duration
    durations.reduce { |a, e| a.merge e }
  end

  def durations_of_day(date)
    date_duration = Duration.new(date.to_time, date.tomorrow.to_time)
    durations.map { |duration| duration.slice(date_duration) }.compact
  end

  def work_time_length
    durations.map(&:length).reduce(0, :+)
  end

  def work_time_length_of_day(date)
    durations_of_day(date).map(&:length).reduce(0, :+)
  end

  def unified_histories
    UnifiedHistory.overlap(durations)
  end

  delegate :file_histories, to: :unified_histories

  delegate :web_histories, to: :unified_histories

  def restore
    unified_histories.map(&:restore)
  end

  def finish
    update_attributes status: true
  end

  def finished?
    status
  end

  def integrated_histories
    IntegratedHistory.integrate(unified_histories)
  end

  def to_occurrences
    durations.map do |d|
      { id:        id,
        title:     name,
        start:     d.start_time.iso8601,
        end:       d.end_time.iso8601,
        type:      'task',
        className: 'task-occurrence' }
    end
  end
end
