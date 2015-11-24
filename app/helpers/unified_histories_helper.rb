module UnifiedHistoriesHelper
  def history_icon(history)
    case history.extension
    when "eml"
      icon = "thunderbird"
    when "html"
      icon = "firefox"
    when "org"
      icon = "emacs"
    when "pdf"
      icon = "preview"
    when "txt"
      icon = "emacs"
    when "xlsx"
      icon = "excel"
    else
      return nil
    end
    return image_tag( "#{icon}.png",
                      {class: "history-icon"} )
  end
end
