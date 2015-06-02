@UI =
  all: (context="body") ->
    # console.log "* Fired UI.all(" + JSON.stringify(context) + ")"
    instanceMethods = (v for k, v of @ when typeof v is "function")
    instanceMethods.shift() # removes the UI.all method from the front of the array
    window[method(context)] for method in instanceMethods

  bootstrap: (context="body") ->
    # console.log " -Fired UI.bootstrap(" + JSON.stringify(context) + ")"

    # XXX not needed?
    $('[data-toggle="popover"]', context).each ->
      $(@).popover
        container: $(@)

    # XXX not needed?
    $('body').on 'click', (event) ->
      $('[data-toggle="popover"]').each ->
        if !$(@).is(event.target) and $(@).has(event.target).length == 0 and $('.popover').has(event.target).length == 0
          $(@).popover 'hide'

    $('input.tokenize', context).tokenfield
      createTokensOnBlur: true
    # XXX for flatlogic BS checkboxen
    # $('.checkbox > label > input[type="checkbox"]').each ->
      # $(@).insertBefore $(@).parent()

  zeroClipboard: (context="body") ->
    clip = new ZeroClipboard $('.copy-link', context)
    clip.on 'aftercopy', (e) ->
      $(e.target).attr 'data-original-title', $(e.target).data('copied-hint')
      $(e.target).tooltip 'show'
      $('.copy-link').not(e.target).attr 'data-original-title', $(e.target).data('copy-hint')
      $('.copy-link').addClass 'btn-info'
      $('.copy-link').removeClass 'btn-success'
      $(e.target).addClass 'btn-success'
      $(e.target).removeClass 'btn-info'

    $('.copy-link', context).each ->
      $(@).tooltip
       title: $(@).data 'copy-hint'
       trigger: 'click hover focus'
       placement: 'bottom'

  fired_once: ->
    # console.log " -Fired UI.fired_once()"
    $('#toggle-checkboxes').on 'click', ->
      new_state = !$(@).data('state')
      $(@).data 'state', new_state
      $('span.glyphicon', @).toggleClass 'glyphicon-check glyphicon-unchecked'
      $('button.row-selector > .glyphicon').toggleClass 'glyphicon-check', new_state
      $('button.row-selector > .glyphicon').toggleClass 'glyphicon-unchecked', !new_state
      $('input[type="checkbox"]', $(@).data('context')).prop 'checked', new_state
      UI.update_multiple_edit_button $('input[type="checkbox"]:checked', $(@).data('context')).length

    $('table.table tbody').on 'click', "button.row-selector", ->
      $('span.glyphicon', @).toggleClass 'glyphicon-check glyphicon-unchecked'
      checkbox = $(@).next 'input[type="checkbox"]'
      checkbox.prop 'checked', !checkbox.prop('checked')
      $('input#toggle-checkboxes').prop 'checked', false
      $('input#toggle-checkboxes').data 'state', false
      UI.update_multiple_edit_button $('input[type="checkbox"]:checked').length

    $('body').on 'keyup change cut paste', 'textarea#credential_public_key', ->
      textarea = $(@)
      if textarea.val().length == 0
        textarea.parent('form-group').next('#key-info').empty()
      else
        $.getJSON(textarea.data('source'), key: $(@).val()).done (json) ->
          key_info = if json.valid
            $('<div class="text-success">').text(json.bits + ' Bits - MD5 fingerprint: ' + json.fingerprint)
          else
            $('<div class="text-danger">').text('Invalid key')
          textarea.parent('.form-group').next('#key-info').html key_info

  update_multiple_edit_button: (count) ->
    # console.log " -Fired UI.update_multiple_edit_button(" + count + ")"
    if count >= 0
      $(".update-multiple").toggleClass "disabled", count == 0
      $("#multiple-count").html count
      $("#multiple-plural").toggleClass "invisible", count == 1

  moment: (context="body") ->
    # console.log " -Fired UI.moment(" + JSON.stringify(context) + ")"
    $('.datetimegroup', context).each ->
      dateFormat = 'YYYY-MM-DD, h:mm A'
      localTime = moment($(@).data('time')).format dateFormat
      $(@).html localTime

  datatables: (context="body") ->
    # console.log " -Fired UI.datatables(" + JSON.stringify(context) + ")"
    $('table[data-source]', context).each ->
      resourceName = $(@).data('resourcename') || 'item'
      initial_sort_column = $(@).find('thead > tr > th').not('[data-orderable="false"]').first().index()
      table = $(@).DataTable
        processing: true
        order: [ initial_sort_column, 'asc' ]
        ajax:
          url: $(@).data('source')
          error: (xhr, ajaxOptions, thrownError) ->
            if xhr.status == 401
              window.location.reload true
        pagingType: 'full_numbers'
        dom: $(@).data('datatable-dom')
        stateSave: false # XXX testing
        responsive: true
        language:
          emptyTable: 'No ' + resourceName + 's available'
          info: 'Showing _START_ to _END_ of _TOTAL_ ' + resourceName + 's'
          infoEmpty: 'Showing 0 to 0 of 0 ' + resourceName + 's'
          infoFiltered: '(filtered from _MAX_ total ' + resourceName + 's)'
          lengthMenu: 'Show _MENU_ ' + resourceName + 's'
          loadingRecords: 'Loading ' + resourceName + 's...'
          processing: 'Crunching!'
          search: 'Search:'
          zeroRecords: 'No matching ' + resourceName + 's found'
        length: -1
        drawCallback: (settings) ->
          UI.bootstrap(@)
          UI.moment(@)
          UI.zeroClipboard(@)
      clear_button = $('<button type="button" disabled="disabled" class="btn btn-default"/>')
      clear_button.append $('<span class="glyphicon glyphicon-remove">')
      clear_button.click ->
        unless search.val() == ''
          $(@).prop 'disabled', true
          table.search('').draw()
      input_group = $('<div class="input-group"/>')
      filter = $(@).closest('.dataTables_wrapper').find('.dataTables_filter')
      search = filter.find 'input[type="search"]'
      search.attr 'placeholder', 'Search'
      search.removeClass 'input-sm'
      search.on 'keyup change cut paste', ->
        clear_button.prop 'disabled', (search.val() == '')
      search.focus(->
        $(@).animate { width: $(@).outerWidth() * 2 }
      ).blur ->
        $(@).animate { width: $(@).outerWidth() / 2 }
      input_group.append search
      input_group.append $('<span class="input-group-btn"/>').append(clear_button)
      filter.html input_group

  alerts: (context="body") ->
    # console.log " -Fired UI.alerts(" + JSON.stringify(context) + ")"
    window.setTimeout (->
      $('.alert', context).fadeTo 500, 0, ->
        $(@).remove()
    ), 3500

  modals: (context="body") ->
    # console.log " -Fired UI.modals(" + JSON.stringify(context) + ")"
    $('table.table tbody').on 'click', 'tr a.edit-link[data-remote="true"]', ->
      $('#update-form-modal .modal-body').html $('<span class="spinner center-block"/>')
      $('#update-form-modal').modal 'show'

    $('table.table tbody').on 'ajax:beforeSend', 'tr a.destroy-link[data-method="delete"]', ->
      $(@).parent().addClass 'disabled'
      $(@).on 'click', false
      $(@).append $('<span class="spinner"/>')

    $('body').on 'ajax:beforeSend', 'form[data-remote="true"]', ->
      $(@).find('.spinner').removeClass 'hidden'

