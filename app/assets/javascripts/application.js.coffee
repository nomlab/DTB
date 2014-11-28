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
#= require jquery-ui
#= require_tree .

ready = ->
  #-------- for minicolors --------
  $('.minicolors').minicolors()

$(document).ready(ready)
$(document).on('page:load', ready)
