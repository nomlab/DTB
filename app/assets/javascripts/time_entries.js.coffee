currentTask = "nil"

initDraggableTimeEntry = -> $(".draggable-time-entry").draggable
  helper: (event) ->
    $("<span style='white-space:nowrap;'>").text "task"
  revert: true

ready = ->
  initDraggableTimeEntry()

  $(".droppable-task-for-task").click (event) ->
    $(".droppable-task-for-task").removeClass "selected"
    $(@).addClass "selected"
    usage = @id
    replaceTimeEntryInbox(usage)

  $(".droppable-task-for-task").droppable
    tolerance: "pointer"
    drop: (event, ui) ->
      timeEntryId = ui.draggable.attr("id")
      taskId =  @id
      $ . ajax
        type:      "PUT"
        url:       "/time_entries/update_task_id/#{timeEntryId}.json?task_id=#{taskId}"
        success: (data) -> replaceTimeEntryInbox(currentTask)
        error: (error) -> alert error

  replaceTimeEntryInbox = (task) ->
    $.ajax
      type:      "GET"
      url:       "/time_entries.json?task_id=#{task}"
      dataType:  "json"
      success: (data) ->
        entries = data.map (timeEntry) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss'
          startTime = moment(timeEntry["start_time"]).format(timeFormat)
          endTime   = moment(timeEntry["end_time"]).format(timeFormat)
          duration = "#{startTime} - #{endTime}"
          """
          <tr class="draggable-time-entry" id="#{timeEntry["id"]}">
            <td>#{timeEntry["name"]}</td>
            <td>#{duration}</td>
          </tr>
          """
        $(".time-entry-inbox").replaceWith("<tbody class='time-entry-inbox'>#{entries}</tbody>")
        initDraggableTimeEntry()
        currentTask = task
      error: (error) -> alert error

$(document).ready(ready)
$(document).on('page:load', ready)
