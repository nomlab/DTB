module ApplicationHelper
  def colored_state(state)
    return content_tag(:span, state.name, :style => "color:#{state.color}")
  end
end
