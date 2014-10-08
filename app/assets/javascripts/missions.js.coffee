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
