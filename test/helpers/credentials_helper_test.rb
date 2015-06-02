require 'test_helper'

# tests for CredentialsHelper methods
class CredentialsHelperTest < ActionView::TestCase
  include ApplicationHelper
  include CredentialsHelper

  test "should return BS classes for public key status" do
    valid_credential    = build_stubbed :alice_credential
    expiring_credential = build_stubbed :alice_credential, :expiring
    expired_credential  = build_stubbed :alice_credential, :expired
    assert_equal 'success', credential_status_class(valid_credential)
    assert_equal 'warning', credential_status_class(expiring_credential)
    assert_equal 'danger', credential_status_class(expired_credential)
  end

  test "should return a BS label with a public key's status" do
    valid_credential = build_stubbed(:alice_credential)
    @output_buffer = credential_status_label(valid_credential)
    assert_select 'span.label.label-success', 1
    assert_select 'span.label.label-success', valid_credential.status
  end

  test "should return a span with a public key broken by nonprinting spaces" do
    key = build_stubbed(:alice_credential).public_key
    @output_buffer = ssh_key_span(key)
    key_with_spaces = key.scan(/.{1,70}/).join('&#8203;')
    # must test that data-content is equal separately
    assert_select "span.ssh-key[data-toggle='popover'][data-trigger='click'][data-content][data-placement='bottom']", 1
    assert_select "span.ssh-key", truncate(key, length: 43)
    assert_equal key_with_spaces, @output_buffer.slice(/data-content="(.+)" /, 1)
  end

  test "should return a span if key is nil" do
    key = nil
    @output_buffer = ssh_key_span(key)
    # must test that data-content is equal separately
    assert_select "span.ssh-key[data-toggle='popover'][data-trigger='click'][data-content][data-placement='bottom']", 1
    assert_select "span.ssh-key", truncate(key, length: 43)
    assert_equal "", @output_buffer.slice(/data-content="(.*)" /, 1)
  end

  test "should return a span if key is blank string" do
    key = ''
    @output_buffer = ssh_key_span(key)
    # must test that data-content is equal separately
    assert_select "span.ssh-key[data-toggle='popover'][data-trigger='click'][data-content][data-placement='bottom']", 1
    assert_select "span.ssh-key", truncate(key, length: 43)
    assert_equal "", @output_buffer.slice(/data-content="(.*)" /, 1)
  end

  test 'key_info should return a key info for a good key' do
    key = build_stubbed(:alice_credential).public_key
    success_string = "#{Credential.key_bits key} Bits - MD5 fingerprint: #{Credential.key_fingerprint key}"
    @output_buffer = key_info(key)
    assert_select 'div.text-success', 1
    assert_select 'div.text-danger', 0
    assert_select 'div.text-success', success_string
  end

  test 'key_info should return an error for a bad key' do
    key = build_stubbed(:alice_credential, :public_key_that_is_too_short).public_key
    error_string = 'is not valid'
    @output_buffer = key_info(key)
    assert_select 'div.text-success', 0
    assert_select 'div.text-danger', 1
    assert_select 'div.text-danger', error_string
  end

  test 'credential expiration progress should return' do
    credential = build_stubbed :alice_credential, :expired
    @output_buffer = expiration(credential)
    assert_select 'span.datetimegroup', 1
    assert_select 'span.duration-left', text: '—', count: 1
    credential = build_stubbed :alice_credential, :expiring
    @output_buffer = expiration(credential)
    assert_select 'span.datetimegroup', 1
    assert_select 'span.duration-left', text: time_ago_in_words(credential.expire_at), count: 1
  end
end
