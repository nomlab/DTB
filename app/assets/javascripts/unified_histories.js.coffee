  $(".droppable").click (event) ->
    usage = event.target.id
    $.ajax
      type:      "GET"
      url:       "/unified_histories.json?usage=#{usage}"
      dataType:  "json"
      success:   (data) ->
        entries = data.map (unified_history) ->
          timeFormat = 'YYYY-MM-DD HH:mm:ss ZZ'
          startTime = moment(unified_history["start_time"]).format(timeFormat)
          endTime   = moment(unified_history["end_time"]).format(timeFormat)
          """
          <tr class="draggable">
            <td>#{unified_history["title"]}</td>
            <td>#{unified_history["path"]}</td>
            <td>#{startTime} - #{endTime}</td>
          </tr>
          """
        $(".inbox").replaceWith("<tbody class='inbox'>#{entries}</tbody>")
        entries = ""
      error:     (error) -> alert error
