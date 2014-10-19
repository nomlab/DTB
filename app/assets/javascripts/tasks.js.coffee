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
    usage = @id
    replaceTaskInbox(usage)

  $(".droppable-mission-for-task").droppable
    tolerance: "pointer"
    drop: (event, ui) ->
      taskId = ui.draggable.attr("id")
      missionId =  @id
      $ . ajax
        type:      "PUT"
        url:       "/tasks/update_mission_id/#{taskId}.json?mission_id=#{missionId}"
        success: (data) -> replaceTaskInbox(currentMissionForTask)
        error: (error) -> alert error

  replaceTaskInbox = (mission) ->
    $.ajax
      type:      "GET"
      url:       "/tasks.json?mission_id=#{mission}"
      dataType:  "json"
      success: (data) ->
        entries = data.map (task) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss'
          statusIcon = if task["status"] then '<span class="icon-ok-sign"></span>' else '<span class="icon-remove-sign"></span>'
          deadline = moment(task["deadline"]).format(timeFormat)
          """
          <tr class="draggable-task" id="#{task["id"]}">
            <td>#{task["name"]}</td>
            <td>#{statusIcon}</td>
            <td>#{deadline}</td>
          </tr>
          """
        $(".task-inbox").replaceWith("<tbody class='task-inbox'>#{entries}</tbody>")
        initDraggableTask()
        currentMissionForTask = mission
      error: (error) -> alert error

$(document).ready(ready)
$(document).on('page:load', ready)
