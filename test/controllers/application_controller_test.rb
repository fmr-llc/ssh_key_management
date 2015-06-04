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
      assert_includes assigns(:authorized_keys), @credential.public_key
      assert_includes assigns(:authorized_keys), @credential2.public_key
    end
    with_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal true, assigns(:cached)
      assert_equal 2, assigns(:authorized_keys).length
      assert_includes assigns(:authorized_keys), @credential.public_key
      assert_includes assigns(:authorized_keys), @credential2.public_key
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
      assert_includes assigns(:authorized_keys), @credential.public_key
      assert_includes assigns(:authorized_keys), @credential2.public_key
    end
    with_caching do
      get :authorized_keys, username: @credential.username, host: @credential.host
      assert_equal true, assigns(:cached)
      assert_equal 2, assigns(:authorized_keys).length
      assert_includes assigns(:authorized_keys), @credential.public_key
      assert_includes assigns(:authorized_keys), @credential2.public_key
    end
  end

  test "authorized_keys should return nothing for unknownuser@hostname" do
    sign_out @user
    get :authorized_keys, username: 'weirdoname', host: 'weirdohost'
    assert_empty assigns(:authorized_keys)
  end

  test "host should register without tags" do
    sign_out @user
    assert_difference('Host.count') do
      post :register_host, host: 'this.is.an.example.com'
      assert_response 200
    end
    assert_no_difference('Host.count') do
      post :register_host, host: 'this.is.an.example.com'
      assert_response 200
    end
  end

  test "host should register with tags" do
    sign_out @user
    taggings = { environment: %w(Testing Testing2), manager: 'Chef' }
    @request.env["RAW_POST_DATA"] = taggings.to_json
    assert_difference('Host.count') do
      post :register_host, host: 'this.is.another.example.com'
      assert_response 200
    end
    assert_equal 1, Host.where(fqdn: 'this.is.another.example.com').count
    taggings.each do |context, tags|
      assert_equal 1, Host.tagged_with(tags, on: context).count
    end
  end

  test "host should register with replacement tags" do
    sign_out @user
    taggings = { environment: %w(Testing Testing2), manager: 'Chef' }
    @request.env["RAW_POST_DATA"] = taggings.to_json
    post :register_host, host: 'this.is.another.example.com'

    new_taggings = { Environments: %w(Production Stable) }
    @request.env["RAW_POST_DATA"] = new_taggings.to_json
    post :register_host, host: 'this.is.another.example.com'

    new_taggings.each do |context, tags|
      assert_equal 1, Host.tagged_with(tags, on: context).count
    end
    taggings.each do |context, tags|
      assert_equal 0, Host.tagged_with(tags, on: context).count
    end
  end
end
