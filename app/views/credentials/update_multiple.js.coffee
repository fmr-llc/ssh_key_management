<% if @credential.valid? %>
  $('#flash-message').html '<%=j render 'flash_messages' %>'
  $('#credential-table').DataTable().ajax.reload()
  $('#multiple-form-modal').modal 'hide'
  $('#multiple-form-modal .modal-body').html $('<div/>').addClass('spinner center-block')
  $('#toggle-checkboxes').prop 'checked', false
  UI.update_multiple_edit_button 0
<% else %>
  $('#multiple-form-modal .modal-body').html '<%=j render 'multiple_form', remote: true %>'
  $('#multiple-form-modal .modal-content').effect 'shake'
<% end %>
  UI.alerts()
