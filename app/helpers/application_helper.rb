# -*- coding: utf-8 -*-
module ApplicationHelper
  def colored_state(state)
    return content_tag(:span, state.name, :style => "color:#{state.color}")
  end

  def date_header(date)
    return date.day == 1 ? content_tag(:th, date.strftime("%b")) : content_tag(:th)
  end

  def colored_box(seconds)
    color_class = 'none' if seconds == 0
    color_class = 'little' if seconds > 0
    color_class = 'a-little' if seconds > 60
    color_class = 'not-a-little' if seconds > 300
    color_class = 'much' if seconds > 600
    return content_tag(:td, "■", :class => color_class, :data_seconds => seconds)
  end
end
