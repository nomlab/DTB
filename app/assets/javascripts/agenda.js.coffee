ready = ->
  #-------- for fullcalendar --------
  $('#calendar').fullCalendar
    lang: 'ja'
    defaultView: 'month'
    header:
      left:  'today prev,next prevYear,nextYear title'
      right: 'agendaDay,agendaWeek,month'
    firstDay: 1 #Monday
    timeFormat:
      month: 'HH:mm'
      week:  'HH:mm'
      day:   'HH:mm'
    axisFormat: 'HH:mm'
    eventSources: [
      {
        url: '/missions.json'
      }
    ]
    eventClick:
      (calEvent, jsEvent, view) ->
        url = "/missions/#{calEvent.id}.json" if calEvent.type == "mission"
        url = "/tasks/#{calEvent.id}.json" if calEvent.type == "task"
        url = "/time_entries/#{calEvent.id}.json" if calEvent.type == "time_entry"
        $ . ajax
          type: "GET"
          dataType: 'json'
          url: url
          success: (events) ->
            $('#calendar').fullCalendar('removeEvents');
            $('#calendar').fullCalendar('addEventSource', events);

  #-------- for treeview --------
  $("#mission_tree").treeview
    animated: "fast"
    collapsed: true

$(document).ready(ready)
$(document).on('page:load', ready)
