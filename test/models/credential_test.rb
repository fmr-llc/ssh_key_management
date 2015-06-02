require 'test_helper'

# Tests all credential methods
class CredentialTest < ActiveSupport::TestCase
  test "credential should not save without all values" do
    credential = Credential.create
    assert_not credential.valid?
  end

  test "credential should save with all values" do
    credential = create :alice_credential
    assert credential.valid?, credential.errors.full_messages
    assert credential.nonexpired?
    assert_not credential.expiring?
    assert_not credential.expired?
  end

  test "public key shouldn't have newlines after save" do
    credential = build_stubbed :alice_credential, :public_key_with_newlines
    assert credential.valid?, credential.errors.full_messages.join('\n')
    assert_equal 0, credential.public_key.count("\n")
  end

  test "credential that is too short shouldn't be valid" do
    credential = build_stubbed :alice_credential, :public_key_that_is_too_short
    assert_not credential.valid?
  end

  test "credential without user shouldn't be valid" do
    credential = build_stubbed :alice_credential, :without_user
    assert_not credential.valid?
  end

  test "credential without public key shouldn't be valid" do
    credential = build_stubbed :alice_credential, :without_public_key
    assert_not credential.valid?
  end

  test "credential without host should be valid" do
    credential = build_stubbed :alice_credential, :without_host
    assert credential.valid?, credential.errors.full_messages
    assert_equal "ANY", credential.host
    refute credential.host?
  end

  test "credential without username shouldn't be valid" do
    credential = build_stubbed :alice_credential, :without_username
    assert_not credential.valid?
  end

  test "credential created over a year should be expired" do
    credential = build_stubbed :alice_credential, :expired
    assert_not credential.nonexpired?
    assert_not credential.expiring?
    assert credential.expired?
  end

  test "credential created >305 days and <1 year should be expiring" do
    credential = build_stubbed :alice_credential, :expiring
    assert credential.nonexpired?
    assert credential.expiring?
    assert_not credential.expired?
  end

  test "credential statuses" do
    valid_credential    = build_stubbed :alice_credential
    expiring_credential = build_stubbed :alice_credential, :expiring
    expired_credential  = build_stubbed :alice_credential, :expired
    assert_equal 'Valid', valid_credential.status
    assert_equal 'Expiring', expiring_credential.status
    assert_equal 'Expired', expired_credential.status
  end

  test "credential logon should return valid user at host" do
    credential = build_stubbed :alice_credential
    assert credential.valid?
    assert_equal "#{credential.username}@#{credential.host}", credential.logon
  end

  test "credential should return expiration time " do
    credential = build_stubbed :alice_credential, :expired
    assert_equal 100, credential.expiration_percentage
    credential = build_stubbed :alice_credential, :expiring
    t = Time.zone.now
    percentage = ((t - credential.created_at) / (credential.expire_at - credential.created_at) * 100).round
    assert_equal percentage, credential.expiration_percentage(t)
  end

  test "hostname should be valid" do
    credential = build_stubbed :alice_credential
    assert credential.valid?
    credential.host = 'test'
    refute credential.valid?
  end

  test "credential can have tags" do
    credential = build :alice_credential
    assert_difference 'credential.tag_list.count' do
      credential.tag_list.add 'Server'
      credential.save
    end
    assert_difference 'credential.tag_list.count', -1 do
      credential.tag_list.remove 'Server'
      credential.save
    end
  end
end
