<% if @credential.destroyed? %>
  $('#credential-table').DataTable().row("tr#credential_" + <%= @credential.id.to_json %>).remove().draw()
  $('#status-area').html '<%= j render 'status_area' %>'
<% else %>
  alert 'Error: Cannot delete!'
  $('#credential-table tr#credential_<%= @credential.id.to_json %> a[data-method="delete"]').off 'click', false
  $('#credential-table tr#credential_<%= @credential.id.to_json %> a[data-method="delete"] .spinner').remove()
  $('#credential-table tr#credential_<%= @credential.id.to_json %> a[data-method="delete"]').parent().removeClass 'disabled'
<% end %>
  $('#flash-message').html '<%=j render 'flash_messages' %>'
  UI.alerts()
