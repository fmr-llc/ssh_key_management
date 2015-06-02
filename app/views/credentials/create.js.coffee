<% if @credential.valid? %>
  $('#create-form-modal').modal 'hide'
  $('#credential-table').DataTable().ajax.reload()
  $('#flash-message').html '<%=j render 'flash_messages' %>'
  $('#status-area').html '<%= j render 'status_area' %>'
  $('#create-form-modal .modal-body').html $('<div/>').addClass('spinner center-block')
<% else %>
  $('#create-form-modal .modal-body').html '<%=j render 'form', remote: true %>'
  $('#create-form-modal .modal-content').effect 'shake'
<% end %>
  UI.alerts()
