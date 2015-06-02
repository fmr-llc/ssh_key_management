$('#credential-table').DataTable().ajax.reload()
$('#status-area').html '<%= j render 'status_area' %>'
$('#flash-message').html '<%=j render 'flash_messages' %>'
UI.update_multiple_edit_button 0
$('#multiple-delete').prop 'disabled', false
UI.alerts()
