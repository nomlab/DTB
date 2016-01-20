module ApplicationHelper
  def colored_state(state)
    content_tag(:span, state.name, style: "color:#{state.color}")
  end

  def colored_box(seconds)
    color_class = ' none' if seconds == 0
    color_class = ' little' if seconds > 0
    color_class = ' a-little' if seconds > 60
    color_class = ' not-a-little' if seconds > 300
    color_class = ' much' if seconds > 600
    m, s = seconds.divmod(60)
    s.to_s.rjust(2, '0')
    seconds_str = "#{m}:#{s}"
    content_tag(:span, '■',
                class: ('timeline-box' + color_class),
                title: "Reference Time: #{seconds_str}",
                data: { toggle: 'tooltip' })
  end

  def seconds_to_s(seconds)
    hour, sec_r = seconds.divmod(3600)
    time_str = (Time.zone.parse('1/1') + sec_r).strftime('%M:%S')
    "#{hour}:#{time_str}"
  end

  def treeview_mission_node(mission)
    content_tag :li do
      concat colored_state(mission.state)
      concat ' '
      concat link_to(mission.name, mission, class: 'mission')
      concat treeview_mission_branch(mission) unless mission.leaf? && mission.tasks.blank?
    end
  end

  def treeview_mission_branch(mission)
    content_tag :ul do
      mission.children.each { |child| concat treeview_mission_node(child) }
      mission.tasks.each { |task| concat treeview_task_node(task) }
    end
  end

  def treeview_task_node(task)
    content_tag :li do
      concat colored_state(task.state)
      concat ' '
      concat link_to(task.name, task, class: 'task')
      concat treeview_task_branch(task) unless task.time_entries.blank?
    end
  end

  def treeview_task_branch(task)
    content_tag :ul do
      task.time_entries.each { |te| concat treeview_time_entry_node(te) }
    end
  end

  def treeview_time_entry_node(time_entry)
    content_tag :li do
      concat link_to(time_entry.name, time_entry, class: 'time-entry')
    end
  end
end
