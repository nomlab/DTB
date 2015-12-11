#= require jquery
#= require bootstrap-sprockets
#= require jquery_ujs
#= require turbolinks
#-- for treeview     --
#= require jquery.treeview
#= require jquery.treeview.edit
#= require jquery.treeview.async
#= require moment
#= require fullcalendar
#= require lang-all
#= require jquery.minicolors
#= require jquery.treegrid
#= require jquery.treegrid.bootstrap3
#= require bootstrap-datetimepicker
#= require chosen-jquery
#= require jquery-ui
#= require_tree .

format =
  'data-date-format': 'YYYY-MM-DD HH:mm:ss'

ready = ->
  $('.minicolors').minicolors()

  $('.datetimepicker').attr(format)
  $('.datetimepicker').datetimepicker
    icons:
      time: "fa fa-clock-o",
      date: "fa fa-calendar",
      up: "fa fa-chevron-up",
      down: "fa fa-chevron-down"

  $("#mission_tree").treeview
    animated: "fast"
    collapsed: true

  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results matched'
    width: '20em'

  $('.timeline-box').tooltip

$(document).ready(ready)
$(document).on('page:load', ready)
