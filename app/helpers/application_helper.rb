# -*- coding: utf-8 -*-
module ApplicationHelper
  def colored_state(state)
    return content_tag(:span, state.name, :style => "color:#{state.color}")
  end

  def colored_box(seconds)
    color_class = ' none' if seconds == 0
    color_class = ' little' if seconds > 0
    color_class = ' a-little' if seconds > 60
    color_class = ' not-a-little' if seconds > 300
    color_class = ' much' if seconds > 600
    return content_tag(:td, "■",
                       :class => ("timeline-box" + color_class),
                       :data_seconds => seconds)
  end

  def seconds_to_s(seconds)
    hour, sec_r = seconds.divmod(3600)
    time_str = (Time.parse("1/1") + sec_r).strftime("%M:%S")
    return "#{hour}:#{time_str}"
  end

  def treeview_mission_node(mission)
    return content_tag :li do
      concat colored_state(mission.state)
      concat " "
      concat link_to( mission.name,
                      { controller: "missions",
                        action:     "show",
                        id:         mission.id },
                      { class:      "mission" } )
      concat treeview_mission_branch(mission) unless mission.leaf? && mission.tasks.blank?
    end
  end

  def treeview_mission_branch(mission)
    content_tag :ul do
      mission.children.each{|child| concat treeview_mission_node(child)}
      mission.tasks.each{|task| concat treeview_task_node(task)}
    end
  end

  def treeview_task_node(task)
    return content_tag :li do
      concat colored_state(task.state)
      concat " "
      concat link_to( task.name,
                      { controller: "tasks",
                        action:     "show",
                        id:         task.id },
                      { class:      "task" } )
      concat treeview_task_branch(task) unless task.time_entries.blank?
    end
  end

  def treeview_task_branch(task)
    content_tag :ul do
      task.time_entries.each{|te| concat treeview_time_entry_node(te)}
    end
  end

  def treeview_time_entry_node(time_entry)
    return content_tag :li do
      concat link_to( time_entry.name,
                      { controller: "time_entries",
                        action:     "show",
                        id:         time_entry.id },
                      { class:      "time-entry" } )
    end
  end
end
