require 'test_helper'

# Test controller to test authentication
class TestableController < ApplicationController
  def show
    fail DeviseLdapAuthenticatable::LdapException, "Bad data from LDAP server"
  end

  def index
    fail Net::LDAP::LdapError, "Cannot access LDAP server"
  end
end

# Tests Application level controller LDAP failures
class ApplicationControllerLDAPTest < ActionController::TestCase
  tests TestableController
  include Devise::TestHelpers

  setup do
    @user = create :alice
    sign_in @user
  end

  test "bad data from LDAP server should raise a 500" do
    with_routing do |map|
      map.draw do
        get :show, controller: :testable, action: :show
      end
      get :show
      assert_response 500
      assert_select 'body', "Bad data from LDAP server"
    end
  end

  test "cannot access LDAP server should raise a 500" do
    with_routing do |map|
      map.draw do
        get :index, controller: :testable, action: :index
      end
      get :index
      assert_response 500
      assert_select 'body', "Cannot access LDAP server"
    end
  end
end

# Tests Application level controller
class ApplicationControllerTest < ActionController::TestCase
  tests ApplicationController
  include Devise::TestHelpers
  include ActionController::Testing::Caching

  setup do
    @user = create :alice
    sign_in @user
  end

  if ENV['F5_HEALTHCHECK']
    test "BigIP health check should return 200 and a string" do
      sign_out @user
      get :f5_health_check
      assert_response 200
      assert_select 'body', text: 'THE SERVER IS UP', count: 1
    end
  end

  test "authorized_keys should get one key for one user@hostname" do
    sign_out @user
    @credential  = build_stubbed :alice_credential
    @credential2 = build_stubbed :alice_credential, :different_key

    Credential.destroy_all
    Credential.create(user: @user, host: @credential.host, public_key: @credential.public_key, username: @credential.username)
    Credential.create(user: @user, host: @credential.host, public_key: @credential.public_key, username: 'other')
    Rails.cache.clear
    without_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal false, assigns(:cached)
      assert_equal 1, assigns(:authorized_keys).length
      assert_equal [@credential.public_key], assigns(:authorized_keys)
    end
    with_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal true, assigns(:cached)
      assert_equal 1, assigns(:authorized_keys).length
      assert_equal [@credential.public_key], assigns(:authorized_keys)
    end
  end

  test "authorized_keys should get two keys for one user with a hostname (including default key)" do
    sign_out @user
    @credential  = build_stubbed :alice_credential
    @credential2 = build_stubbed :alice_credential, :default_key

    Credential.destroy_all
    Credential.create(user: @user, host: @credential.host, public_key: @credential.public_key, username: @credential.username)
    Credential.create(user: @user, public_key: @credential2.public_key, username: @credential2.username)
    Rails.cache.clear
    without_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal false, assigns(:cached)
      assert_equal 2, assigns(:authorized_keys).length
      assert_equal [@credential.public_key, @credential2.public_key], assigns(:authorized_keys)
    end
    with_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal true, assigns(:cached)
      assert_equal 2, assigns(:authorized_keys).length
      assert_equal [@credential.public_key, @credential2.public_key], assigns(:authorized_keys)
    end
  end

  test "authorized_keys should get two keys for multiple user@hostname" do
    sign_out @user
    @credential  = build_stubbed :alice_credential
    @credential2 = build_stubbed :alice_credential, :different_key

    Credential.destroy_all
    Credential.create(user: @user, host: @credential.host, public_key: @credential.public_key, username: @credential.username)
    Credential.create(user: @user, host: @credential2.host, public_key: @credential2.public_key, username: @credential2.username)
    Rails.cache.clear
    without_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal false, assigns(:cached)
      assert_equal 2, assigns(:authorized_keys).length
      assert_equal [@credential.public_key, @credential2.public_key], assigns(:authorized_keys)
    end
    with_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal true, assigns(:cached)
      assert_equal 2, assigns(:authorized_keys).length
      assert_equal [@credential.public_key, @credential2.public_key], assigns(:authorized_keys)
    end
  end

  test "authorized_keys should return nothing for unknownuser@hostname" do
    sign_out @user
    get :authorized_keys, username: 'weirdoname', host: 'weirdohost'
    assert_empty assigns(:authorized_keys)
  end
end
