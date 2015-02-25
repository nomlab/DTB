class Mission < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  # Choice acts_as_nested_set or has_many :children and belongs_to :parent.
  # If you choice acts_as_nested_set, activate following two line
  acts_as_nested_set
  after_save :rebuild_nested_set
  # has_many :children, :class_name => "Mission", :foreign_key => :parent_id
  # belongs_to :parent, :class_name => "Mission", :foreign_key => :parent_id
  belongs_to :state
  default_scope { order(created_at: :desc) }

  def durations
    return children.map(&:durations).flatten + tasks.map(&:durations).flatten
  end

  def duration
    return durations.inject{|d1, d2| d1.merge d2}
  end

  def unified_histories
    return (children.map(&:unified_histories) +
            tasks.map(&:unified_histories)).flatten.uniq
  end

  def file_histories
    return (children.map(&:file_histories) +
            tasks.map(&:file_histories)).flatten.uniq
  end

  def web_histories
    return (children.map(&:web_histories) +
            tasks.map(&:web_histories)).flatten.uniq
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
      start:     duration.start_time,
      end:       duration.end_time,
      type:      "mission",
      color:     "#9FC6E7",
      textColor: "#000000"
    }
  end

  def progress
    all_tasks = children.map(&:tasks).flatten + tasks
    completed = all_tasks.select(&:status)
    return (completed.length.to_f / all_tasks.length.to_f) * 100
  end

  private
  # If you choice has_many :children and belongs_to :parent,
  # deactivate following methods

  def rebuild_nested_set
    Mission.rebuild!
  end
end
