ready = ->
  #-------- for fullcalendar --------
  $('#calendar').fullCalendar
    lang: 'en'
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
      url: '/missions.occurrence?root=true'
    ]

  #-------- for treegrid --------
  $(".table-treegrid").treegrid
    initialState: "collapsed"
    expanderExpandedClass: 'fa fa-chevron-down'
    expanderCollapsedClass: 'fa fa-chevron-right'

$(document).on 'ready page:load', ready
