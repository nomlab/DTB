currentMissionForMission = "nil"

initDraggableMission = -> $(".draggable-mission").draggable
  helper: (event) ->
    $("<span style='white-space:nowrap;'>").text "mission"
  revert: true

ready = ->
  initDraggableMission()

  $(".droppable-mission-for-mission").click (event) ->
    $(".droppable-mission-for-mission").removeClass "selected"
    $(@).addClass "selected"
    parentId = @id
    replaceMissionInbox(parentId)

  $(".droppable-mission-for-mission").droppable
    tolerance: "pointer"
    drop: (event, ui) ->
      missionId = ui.draggable.attr("id")
      parentId =  @id
      $ . ajax
        type:      "PUT"
        url:       "/missions/update_parent_id/#{missionId}.json?parent_id=#{parentId}"
        success: (data) -> replaceMissionInbox(currentMissionForMission)
        error: (error) -> alert error

  replaceMissionInbox = (parentId) ->
    $.ajax
      type:      "GET"
      url:       "/missions.json?parent_id=#{parentId}"
      dataType:  "json"
      success: (data) ->
        entries = data.map (mission) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss'
          deadline = if moment(mission["deadline"]).format(timeFormat) == "Invalid date" then "" else moment(mission["deadline"]).format(timeFormat)
          deadline = if deadline == "Invalid date" then "" else deadline
          """
          <tr class="draggable-mission" id="#{mission["id"]}">
            <td>#{mission["name"]}</td>
            <td>#{deadline}</td>
          </tr>
          """
        $(".mission-inbox").replaceWith("<tbody class='mission-inbox'>#{entries}</tbody>")
        initDraggableMission()
        currentMissionForTask = parentId
      error: (error) -> alert error

$(document).ready(ready)
$(document).on('page:load', ready)
