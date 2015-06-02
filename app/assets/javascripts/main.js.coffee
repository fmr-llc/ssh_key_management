ready = ->
  console.log "Fired ready()"
  UI.all()

  # thrownError is 'Unauthorized' to have Devise redirect back to sign in page
  $.fn.dataTable.ext.errMode = 'throw'
  $(document).ajaxError (event, jqxhr, settings, thrownError) ->
    if jqxhr.status == 401
      alert "Timed out to inactivity"
      # force reload on general xhr 401
      window.location.reload true

$(document).ready ready
$(document).on 'page:load', ready