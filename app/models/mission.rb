class Mission < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  # Choice acts_as_nested_set or has_many :children and belongs_to :parent.
  # If you choice acts_as_nested_set, activate following two line
  acts_as_nested_set
  after_save :rebuild_nested_set
  # has_many :children, :class_name => "Mission", :foreign_key => :parent_id
  # belongs_to :parent, :class_name => "Mission", :foreign_key => :parent_id
  belongs_to :state
  default_scope { includes(:state, tasks: :time_entries).order(created_at: :desc) }

  def durations
    return children.map(&:durations).flatten + tasks.map(&:durations).flatten
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
    UnifiedHistory.overlap(durations)
  end

  def file_histories
    return unified_histories.file_histories
  end

  def web_histories
    return unified_histories.web_histories
  end

  # If you choice has_many :children and belongs_to :parent,
  # activate following two methods

  # def root
  #   root? ? self : parent.root
  # end

  # def root?
  #   !parent
  # end

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
        type:      "mission",
        className: "mission-occurrence"
      }
    end
  end

  private
  # If you choice has_many :children and belongs_to :parent,
  # deactivate following methods

  def rebuild_nested_set
    Mission.rebuild!
  end
end
