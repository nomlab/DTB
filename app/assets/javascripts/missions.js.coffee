$ ->
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
        $ . ajax
          type : "GET"
          dataType: 'json'
          url :  "/missions/#{calEvent.id}.json"
          success : (events) ->
            $('#calendar').fullCalendar('removeEvents');
            $('#calendar').fullCalendar('addEventSource', events);
