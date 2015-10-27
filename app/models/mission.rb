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

  def unified_histories
    return [] if duration.nil?
    candidates = UnifiedHistory.in(duration.start_time, duration.end_time)
    return candidates.select do |c|
      durations.select{|d| d.overlap?(c) }.present?
    end
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

  def to_event
    return {
      id:        id,
      title:     name,
      start:     deadline,
      type:      "mission",
      color:     "#9FC6E7",
      textColor: "#000000"
    }
  end

  private
  # If you choice has_many :children and belongs_to :parent,
  # deactivate following methods

  def rebuild_nested_set
    Mission.rebuild!
  end
end
