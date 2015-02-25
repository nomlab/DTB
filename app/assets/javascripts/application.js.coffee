#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require turbolinks
#-- for treeview     --
#= require jquery.treeview
#= require jquery.treeview.edit
#= require jquery.treeview.async
#----------------------
#-- for fullcalendar --
#= require moment
#= require fullcalendar
#= require lang-all
#----------------------
#-- for minicolors ----
#= require jquery.minicolors
#----------------------
#-- for treegrid ------
#= require jquery.treegrid
#= require jquery.treegrid.bootstrap3
#----------------------
#-- for datetimepicker ------
#= require bootstrap-datetimepicker
#----------------------
#-- for jquery.balloon.js ------
#= require jquery.balloon.js
#----------------------
#= require jquery-ui
#= require_tree .

format =
  'data-date-format': 'YYYY-MM-DD HH:mm:ss'

ready = ->
  #-------- for minicolors --------
  $('.minicolors').minicolors()

  #-------- for datetimepicker ----
  $('.datetimepicker').attr(format)
  $('.datetimepicker').datetimepicker
    icons:
      time: "fa fa-clock-o",
      date: "fa fa-calendar",
      up: "fa fa-chevron-up",
      down: "fa fa-chevron-down"

  #-------- for treeview --------
  $("#mission_tree").treeview
    animated: "fast"
    collapsed: true

$(document).ready(ready)
$(document).on('page:load', ready)
