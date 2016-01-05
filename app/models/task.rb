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
    tbl   = UnifiedHistory.arel_table
    durs  = durations
    d     = durs.pop
    initial_nodes = tbl[:start_time].gteq(d.start_time).and(tbl[:start_time].lteq(d.end_time))
                    .or(tbl[:end_time].gteq(d.start_time).and(tbl[:end_time].lteq(d.end_time)))
    nodes = durs.inject(initial_nodes) do |nodes, d|
      nodes.or(tbl[:start_time].gteq(d.start_time).and(tbl[:start_time].lteq(d.end_time))
                .or(tbl[:end_time].gteq(d.start_time).and(tbl[:end_time].lteq(d.end_time))))
    end
    UnifiedHistory.where(nodes)
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

  def finish
    self.update_attributes :status => true
  end

  def finished?
    return self.status
  end

  def integrated_histories
    IntegratedHistory.integrate(unified_histories)
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
