currentUsage = "undefined"

initDraggable = -> $(".draggable").draggable
  helper: (event) ->
    $("<span style='white-space:nowrap;'>").text "item"
  revert: true

$ ->
  initDraggable()

  $(".droppable").click (event) ->
    $(".droppable").removeClass "selected"
    $(@).addClass "selected"
    usage = @id
    replaceInbox(usage)

  $(".droppable").droppable
    tolerance: "pointer"
    drop: (event, ui) ->
      unifiedHistoryId = ui.draggable.attr("id")
      usage =  @id
      $ . ajax
        type:      "PUT"
        url:       "/unified_histories/update_usage/#{unifiedHistoryId}.json?usage=#{usage}"
        success: (data) -> replaceInbox(currentUsage)
        error: (error) -> alert error

  replaceInbox = (usage) ->
    $.ajax
      type:      "GET"
      url:       "/unified_histories.json?usage=#{usage}"
      dataType:  "json"
      success: (data) ->
        entries = data.map (unified_history) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss ZZ'
          startTime = moment(unified_history["start_time"]).format(timeFormat)
          endTime   = moment(unified_history["end_time"]).format(timeFormat)
          """
          <tr class="draggable" id="#{unified_history["id"]}">
            <td>#{unified_history["title"]}</td>
            <td>#{unified_history["path"]}</td>
            <td>#{startTime} - #{endTime}</td>
          </tr>
          """
        $(".inbox").replaceWith("<tbody class='inbox'>#{entries}</tbody>")
        initDraggable()
        currentUsage = usage
      error: (error) -> alert error
