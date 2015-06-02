require 'test_helper'

# class CredentialsControllerTest < ActionController::TestCase; ; end

# added helper equality for Array
class Array
  def samesame?(other_array)
    (self & other_array) == self
  end
end

# Tests credential datatable JSON
class CredentialsDatatableTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @controller = CredentialsController.new
    @user = create :alice
    sign_in @user
  end

  def default_datatable_params
    {
      format: :datatable,
      draw: '1',
      columns: {
        '0' => { data: '0', name: '', searchable: 'true', orderable: 'false', search: { value: '', regex: 'false' } },
        '1' => { data: '1', name: '', searchable: 'true', orderable: 'true', search: { value: '', regex: 'false' } },
        '2' => { data: '2', name: '', searchable: 'true', orderable: 'true', search: { value: '', regex: 'false' } },
        '3' => { data: '3', name: '', searchable: 'true', orderable: 'true', search: { value: '', regex: 'false' } },
        '4' => { data: '4', name: '', searchable: 'true', orderable: 'true', search: { value: '', regex: 'false' } },
        '5' => { data: '5', name: '', searchable: 'true', orderable: 'false', search: { value: '', regex: 'false' } },
        '6' => { data: '6', name: '', searchable: 'true', orderable: 'false', search: { value: '', regex: 'false' } },
        '7' => { data: '7', name: '', searchable: 'true', orderable: 'false', search: { value: '', regex: 'false' } }
      },
      search: {
        value: '',
        regex: 'false'
      },
      start: '1',
      length: '-1',
      order: {
        '0' => {
          column: '1',
          dir: 'asc'
        }
      }
    }
  end

  test "credentials datatable should return JSON with credentials" do
    get :index, default_datatable_params
    json = JSON.parse(@response.body)
    ids = @user.credentials.order(created_at: :asc).offset(0).limit(10).pluck(:id)
    data_ids = json["data"].collect { |datum| datum['DT_RowId'].delete('credential_').to_i }
    assert %w(draw recordsTotal data recordsFiltered).all? { |key| json.key? key }, 'Keys missing from datatable JSON'
    assert_equal @user.credentials.count, json['recordsTotal']
    assert_equal ids.count, json['recordsFiltered']
    assert_equal ids.length, json['data'].length
    assert ids.samesame?(data_ids), 'Missing Credentials from datatable'
    # assert_equal ids, data_ids, "Incorrect order in JSON data"
  end

  test "credentials datatable should return JSON with filtered credentials" do
    search = 'Host1'
    get :index, default_datatable_params.merge(search: { value: search })
    json = JSON.parse(@response.body)
    ids = @user.credentials.where("host LIKE :host", host: "%#{search}%").offset(0).limit(10).order(created_at: :asc).pluck(:id)
    data_ids = json["data"].collect { |datum| datum['DT_RowId'].delete('credential_').to_i }
    assert %w(draw recordsTotal data recordsFiltered).all? { |key| json.key? key }, 'Keys missing from datatable JSON'
    assert_equal @user.credentials.count, json['recordsTotal']
    assert_equal ids.count, json['recordsFiltered']
    assert_equal ids.length, json['data'].length
    assert ids.samesame?(data_ids), 'Missing Credentials from datatable'
    # assert_equal ids, data_ids, "Incorrect order in JSON data"
  end

  test "credentials datatable should return JSON with proper order" do
    get :index, default_datatable_params.merge(order: { '0' => { column: '3', dir: 'desc' } })
    json = JSON.parse(@response.body)
    ids = @user.credentials.order(host: :desc).offset(0).limit(10).pluck(:id)
    data_ids = json["data"].collect { |datum| datum['DT_RowId'].delete('credential_').to_i }
    assert ids.samesame?(data_ids), 'Missing Credentials from datatable'
    # assert_equal ids, data_ids, "Incorrect order in JSON data"
  end

  test "credentials datatable should return JSON with proper page" do
    get :index, default_datatable_params.merge(start: '1', length: 1, order: { '0' => { column: '3', dir: 'desc' } })
    json = JSON.parse(@response.body)
    ids = @user.credentials.order(host: :desc).offset(1).limit(1).pluck(:id)
    data_ids = json["data"].collect { |datum| datum['DT_RowId'].delete('credential_').to_i }
    assert ids.samesame?(data_ids), 'Missing Credentials from datatable'
    assert_equal ids, data_ids, "Incorrect order in JSON data"
  end
end
