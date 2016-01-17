currentTask = "nil"

initDraggableTimeEntry = -> $(".draggable-time-entry").draggable
  helper: (event) ->
    $("<span style='white-space:nowrap;'>").text "time entry"
  revert: true

ready = ->
  initDraggableTimeEntry()

  $(".droppable-task-for-time-entry").click (event) ->
    $(".droppable-task-for-time-entry").removeClass "selected"
    $(@).addClass "selected"
    usage = @id
    replaceTimeEntryInbox(usage)

  $(".droppable-task-for-time-entry").droppable
    tolerance: "pointer"
    drop: (event, ui) ->
      timeEntryId = ui.draggable.attr("id")
      taskId =  @id
      $ . ajax
        type: "PATCH"
        data: $.param
          time_entry:
            task_id: taskId
        url: "/time_entries/#{timeEntryId}.json"
        success: (data) -> replaceTimeEntryInbox(currentTask)
        error: (error) -> alert error

  replaceTimeEntryInbox = (taskId) ->
    param = if taskId then "task_id=#{taskId}" else "unorganized=true"
    $.ajax
      type:      "GET"
      url:       "/time_entries.json?#{param}"
      dataType:  "json"
      success: (data) ->
        entries = data.map (timeEntry) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss'
          try
            startTime = moment(timeEntry["start_time"]).format(timeFormat)
            endTime   = moment(timeEntry["end_time"]).format(timeFormat)
            duration = "#{startTime} - #{endTime}"
          catch
            duration  = "Not performed."
          """
          <tr class="draggable-time-entry" id="#{timeEntry["id"]}">
            <td>#{timeEntry["name"]}</td>
            <td>#{duration}</td>
          </tr>
          """
        $(".time-entry-inbox").replaceWith("<tbody class='time-entry-inbox'>#{entries}</tbody>")
        initDraggableTimeEntry()
        currentTask = taskId
      error: (error) -> alert error

$(document).on 'ready page:load', ready
