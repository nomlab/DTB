currentMissionForTask = "nil"

initDraggableTask = -> $(".draggable-task").draggable
  helper: (event) ->
    $("<span style='white-space:nowrap;'>").text "task"
  revert: true

ready = ->
  initDraggableTask()

  $(".droppable-mission-for-task").click (event) ->
    $(".droppable-mission-for-task").removeClass "selected"
    $(@).addClass "selected"
    missionId = @id
    replaceTaskInbox(missionId)

  $(".droppable-mission-for-task").droppable
    tolerance: "pointer"
    drop: (event, ui) ->
      taskId = ui.draggable.attr("id")
      missionId =  @id
      $ . ajax
        type: "PATCH"
        data: $.param
          task:
            mission_id: missionId
        url:  "/tasks/#{taskId}.json"
        success: (data) -> replaceTaskInbox(currentMissionForTask)
        error: (error) -> alert error

  replaceTaskInbox = (missionId) ->
    param = if missionId then "mission_id=#{missionId}" else "unorganized=true"
    $.ajax
      type:      "GET"
      url:       "/tasks.json?#{param}"
      dataType:  "json"
      success: (data) ->
        entries = data.map (task) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss'
          try
            startTime = moment(task["duration"]["start_time"]).format(timeFormat)
            endTime   = moment(task["duration"]["end_time"]).format(timeFormat)
            duration = "#{startTime} - #{endTime}"
          catch
            duration  = "Not performed."
          """
          <tr class="draggable-task" id="#{task["id"]}">
            <td>#{task["name"]}</td>
            <td>#{duration}</td>
          </tr>
          """
        $(".task-inbox").replaceWith("<tbody class='task-inbox'>#{entries}</tbody>")
        initDraggableTask()
        currentMissionForTask = missionId
      error: (error) -> alert error

$(document).on 'ready page:load', ready
