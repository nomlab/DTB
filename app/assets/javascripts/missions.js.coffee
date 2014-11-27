ready = ->
  #-------- for modal window --------
  $(".new-mission").click (event) ->
    $('#simple-mission-form').modal('show')

$(document).ready(ready)
$(document).on('page:load', ready)
