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
        url:       "/missions/#{missionId}/update_parent_id.json?parent_id=#{parentId}"
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
          try
            startTime = moment(mission["duration"]["start_time"]).format(timeFormat)
            endTime   = moment(mission["duration"]["end_time"]).format(timeFormat)
            duration  = "#{startTime} - #{endTime}"
          catch
            duration  = "Not performed."
          """
          <tr class="draggable-mission" id="#{mission["id"]}">
            <td>#{mission["name"]}</td>
            <td>#{duration}</td>
          </tr>
          """
        $(".mission-inbox").replaceWith("<tbody class='mission-inbox'>#{entries}</tbody>")
        initDraggableMission()
        currentMissionForTask = parentId
      error: (error) -> alert error

$(document).on 'ready page:load', ready
