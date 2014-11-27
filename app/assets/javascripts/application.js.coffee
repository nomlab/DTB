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
#= require jquery.minicolors
#= require jquery-ui
#= require_tree .

ready = ->
  #-------- for minicolors --------
  $('.minicolors').minicolors()

$(document).ready(ready)
$(document).on('page:load', ready)
