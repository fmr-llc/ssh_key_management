<% if @credential.valid? %>
  $('#flash-message').html '<%=j render 'flash_messages' %>'
  $('#credential-table').DataTable().ajax.reload()
  $('#update-form-modal').modal 'hide'
  $('#update-form-modal .modal-body').html $('<div/>').addClass('spinner center-block')
<% else %>
  $('#update-form-modal .modal-body').html '<%=j render 'form', remote: true %>'
  $('#update-form-modal .modal-content').effect 'shake'
<% end %>
  UI.alerts()
