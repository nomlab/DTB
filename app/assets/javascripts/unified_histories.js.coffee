currentUsage = "undefined"

initDraggableUnifiedHistory = -> $(".draggable-unified-history").draggable
  helper: (event) ->
    $("<span style='white-space:nowrap;'>").text "item"
  revert: true

ready = ->
  initDraggableUnifiedHistory()

  $(".droppable-usage").click (event) ->
    $(".droppable-usage").removeClass "selected"
    $(@).addClass "selected"
    usage = @id
    replaceUnifiedHistoryInbox(usage)

  $(".droppable-usage").droppable
    tolerance: "pointer"
    drop: (event, ui) ->
      unifiedHistoryId = ui.draggable.attr("id")
      usage =  @id
      $ . ajax
        type:      "PUT"
        url:       "/unified_histories/update_usage/#{unifiedHistoryId}.json?usage=#{usage}"
        success: (data) -> replaceUnifiedHistoryInbox(currentUsage)
        error: (error) -> alert error

  replaceUnifiedHistoryInbox = (usage) ->
    $.ajax
      type:      "GET"
      url:       "/unified_histories.json?usage=#{usage}"
      dataType:  "json"
      success: (data) ->
        entries = data.map (unified_history) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss'
          startTime = moment(unified_history["start_time"]).format(timeFormat)
          endTime   = moment(unified_history["end_time"]).format(timeFormat)
          """
          <tr class="draggable-unified-history" id="#{unified_history["id"]}">
            <td>#{unified_history["title"]}</td>
            <td>#{unified_history["path"]}</td>
            <td>#{startTime} - #{endTime}</td>
          </tr>
          """
        $(".unified-history-inbox").replaceWith("<tbody class='unified-history-inbox'>#{entries}</tbody>")
        initDraggableUnifiedHistory()
        currentUsage = usage
      error: (error) -> alert error

$(document).ready(ready)
$(document).on('page:load', ready)
