require 'test_helper'

# Tests all Host model
class HostTest < ActiveSupport::TestCase
  test "host must have a fqdn" do
    host = Host.new
    refute host.valid?
    host = build_stubbed :host
    assert host.valid?
  end
end
