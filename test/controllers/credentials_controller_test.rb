require 'test_helper'

# Tests CRUD and authorization of Credentials with Users
class CredentialsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = create :alice_with_credentials, credentials_count: 2
    @credential = @user.credentials.first
    sign_in @user
  end

  test "not authenticated user should get redirect" do
    sign_out @user
    get :index
    assert_response :redirect
    assert_nil assigns(:credentials)
  end

  test "authenticated user should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:credentials)
    assert_equal @user.credentials, assigns(:credentials)
    assert_equal @user.credentials.count, assigns(:credentials).length
  end

  test "authenticated user should get new" do
    get :new
    assert_response :success
    assert assigns(:credentials)
    assert assigns(:credential)
    assert_not assigns(:credential).persisted?
  end

  test "authenticated user should get new with default username set" do
    get :new
    assert_equal @user.username, assigns(:credential).username
    assert_response :success
  end

  test "authenticated user should create credential" do
    assert_difference 'Credential.count' do
      post :create, credential: {
        host: @credential.host,
        public_key: @credential.public_key,
        username: @credential.username
      }
    end

    assert_equal @user, assigns(:credential).user
    assert_redirected_to credential_path(assigns(:credential))
  end

  test "authenticated user should create credential with tags" do
    assert_difference 'Credential.count' do
      post :create, credential: {
        host: @credential.host,
        public_key: @credential.public_key,
        username: @credential.username,
        tag_list: 'Production,Test'
      }
    end

    assert_includes assigns(:credential).tag_list, 'Production'
    assert_includes assigns(:credential).tag_list, 'Test'
    assert_redirected_to credential_path(assigns(:credential))
  end

  test "authenticated user should create credential with a different username" do
    assert_difference 'Credential.count' do
      post :create, credential: { host: @credential.host, public_key: @credential.public_key, username: 'root' }
    end
    assert_equal @user, assigns(:credential).user
    assert_equal 'root', assigns(:credential).username
    assert_redirected_to credential_path(assigns(:credential))
  end

  test "authenticated user should show credential" do
    get :show, id: @credential
    assert_response :success
    assert assigns(:credential)
  end

  test "authenticated user should get edit" do
    get :edit, id: @credential
    assert_response :success
    assert_equal @credential.id, assigns(:credential).id
  end

  test "authenticated user should update credential" do
    new_host = 'api.rubyonrails.org'.downcase
    patch :update, id: @credential, credential: { host: new_host }
    assert_redirected_to credential_path(assigns(:credential))
    assert_equal new_host, @credential.reload.host
  end

  test "authenticated user should destroy credential" do
    assert_difference('Credential.count', -1) do
      delete :destroy, id: @credential
    end

    assert_redirected_to credentials_path
  end

  test "authenticated user should update multiple credentials with same public keys returned" do
    new_public_key = SSHKey.generate.ssh_public_key
    credentials = @user.credentials.take 2
    credentials_ids = credentials.map(&:id)
    patch :update_multiple, ids: credentials_ids, credential: { public_key: new_public_key }
    assert_redirected_to credentials_path
    assigns(:credentials).each do |credential|
      assert_equal new_public_key, credential.reload.public_key
    end
    returned_public_keys_ids = assigns(:credentials).map(&:id)
    assert returned_public_keys_ids & credentials_ids == returned_public_keys_ids
  end

  test "authenticated user should fail to update multiple credentials with a bad public key" do
    new_public_key = SSHKey.generate.ssh_public_key
    credentials = @user.credentials.take 2
    patch :update_multiple, ids: credentials.map(&:id), credential: { oublic_key: new_public_key }
    assigns(:credentials).each do |credential|
      assert_not_equal new_public_key, credential.reload.public_key
    end
  end

  test "authenticated user should have credential assigned for edit multiple from credentials" do
    credentials = @user.credentials.take 2
    post :edit_multiple, ids: credentials.map(&:id)
    assert_equal credentials, assigns(:credentials)
    assert_equal credentials.first, assigns(:credential)
  end

  test "authenticated user should delete multiple credentials" do
    credentials = @user.credentials.take 2
    assert_difference('Credential.count', -2) do
      post :edit_multiple, ids: credentials.map(&:id), delete: true, xhr: :true, format: :js
    end
    assert_template layout: nil
    assert_response :success
  end

  test "authenticated user should get fingerprint for good key" do
    key = attributes_for(:alice_credential)[:public_key]
    get :key_info, key: key
    assert assigns(:key_info)

    assert_equal Credential.key_valid?(key), assigns(:key_info)[:valid]
    assert_equal Credential.key_bits(key), assigns(:key_info)[:bits]
    assert_equal Credential.key_fingerprint(key), assigns(:key_info)[:fingerprint]
  end

  test "authenticated user should get 'invalid' for bad key" do
    key = attributes_for(:alice_credential, :public_key_that_is_too_short)[:public_key]
    get :key_info, key: key
    assert assigns(:key_info)

    assert_equal Credential.key_valid?(key), assigns(:key_info)[:valid]
    assert_equal false, assigns(:key_info).key?(:bits)
    assert_equal false, assigns(:key_info).key?(:fingerprint)
  end
end
