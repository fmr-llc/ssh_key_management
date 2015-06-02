# defines a class
class CredentialsDatatable < AjaxDatatablesRails::Base
  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= [
      'Credential.created_at',
      'Credential.username',
      'Credential.host',
      'Credential.created_at'
    ]
  end

  def searchable_columns
    @searchable_columns ||= [
      'Credential.created_at',
      'Credential.public_key',
      'Credential.username',
      'Credential.host'
    ]
  end

  private

  def data
    records.map do |credential|
      {
        '0' => view.multiple_edit_checkbox(credential),
        '1' => view.credential_status_label(credential),
        '2' => view.expiration(credential),
        '3' => credential.username,
        '4' => credential.host,
        '5' => view.bs_labels_for_tags(credential.tags),
        '6' => view.action_btns_for(credential),
        '7' => credential.public_key,
        'DT_RowClass' => credential.default_key? ? 'info' : '',
        'DT_RowId' => "credential_#{credential.id}",
        'DT_RowData' => { source: view.credential_path(credential) }
      }
    end
  end

  # rubocop:disable Style/AccessorMethodName
  def get_raw_records
    options[:collection]
  end
  # rubocop:enable Style/AccessorMethodName
end
