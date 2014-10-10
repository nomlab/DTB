class Mission < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  has_many :children, :class_name => "Mission", :foreign_key => :parent_id
  belongs_to :parent, :class_name => "Mission", :foreign_key => :parent_id

  def durations
    return children.map(&:durations).flatten + tasks.map(&:durations).flatten
  end

  def duration
    time_array = durations.map(&:values).flatten.compact
    return {start_time: time_array.min, end_time: time_array.max}
  end

  def unified_histories
    return tasks.map(&:unified_histories).flatten
  end

  def file_histories
    return tasks.map(&:file_histories).flatten
  end

  def web_histories
    return tasks.map(&:web_histories).flatten
  end

  def parent
    parent_id ? Mission.find_by_id(parent_id) : nil
  end

  def children
    Mission.where(:parent_id => id)
  end

  def root
    root? ? self : parent.root
  end

  def root?
    !parent
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
      start:     duration[:start_time],
      end:       duration[:end_time],
      type:      "mission",
      color:     "#D6F0FE",
      textColor: "#000000"
    }
  end
end
