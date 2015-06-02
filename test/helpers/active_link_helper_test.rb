require 'test_helper'

# tests for active_link? method
class ActiveLinkHelperTest < ActionView::TestCase
  include ApplicationHelper

  def request
    OpenStruct.new fullpath: @fullpath
  end

  def params
    @params ||= {}
  end

  test 'active_link? with booleans' do
    assert active_link?('/', true)
    assert !active_link?('/', false)
  end

  test 'active_link?  with :inclusive' do
    @fullpath = '/root'
    assert active_link?('/root', :inclusive)

    @fullpath = '/root?param=test'
    assert active_link?('/root', :inclusive)

    @fullpath = '/root/child/sub-child'
    assert active_link?('/root', :inclusive)

    @fullpath = '/other'
    assert !active_link?('/root', :inclusive)
  end

  test 'active_link? with :inclusive implied' do
    @fullpath = '/root/child/sub-child'
    assert active_link?('/root')
  end

  test 'active_link? with :inclusive similar path' do
    @fullpath = '/root/abc'
    assert !active_link?('/root/a', :inclusive)
  end

  test 'active_link? with :inclusive and last slash' do
    @fullpath = '/root/abc'
    assert active_link?('/root/')
  end

  test 'active_link? :inclusive and last slash and similar path' do
    @fullpath = '/root_path'
    assert !active_link?('/root/')
  end

  test 'active_link? :inclusive and link params' do
    @fullpath = '/root?param=test'
    assert active_link?('/root?attr=example')
  end

  test 'active_link? :exclusive' do
    @fullpath = '/root'
    assert active_link?('/root', :exclusive)

    @fullpath = '/root?param=test'
    assert active_link?('/root', :exclusive)

    @fullpath = '/root/child'
    assert !active_link?('/root', :exclusive)
  end

  test 'active_link? :exclusive and link params' do
    @fullpath = '/root?param=test'
    assert active_link?('/root?attr=example', :exclusive)
  end

  test 'active_link? with :exact' do
    @fullpath = '/root?param=test'
    assert active_link?('/root?param=test', :exact)

    @fullpath = '/root?param=test'
    refute active_link?('/root?param=exact', :exact)

    @fullpath = '/root'
    refute active_link?('/root?param=test', :exact)

    @fullpath = '/root?param=test'
    refute active_link?('/root', :exact)
  end

  test 'active_link? with regex' do
    @fullpath = '/root'
    assert active_link?('/', %r{^\/root})

    @fullpath = '/root/child'
    assert active_link?('/', %r{^\/r})

    @fullpath = '/other'
    assert !active_link?('/', %r{^\/r})
  end

  test 'active_link? with partial hash' do
    @params = {}
    @params[:a] = 1

    assert active_link?('/', a: 1)
    assert active_link?('/', a: 1, b: nil)

    assert !active_link?('/', a: 1, b: 2)
    assert !active_link?('/', a: 2)
  end

  test 'active_link? with complete hash' do
    @params = {}
    @params[:a] = 1
    @params[:b] = 2

    assert active_link?('/', a: 1, b: 2)
    assert active_link?('/', a: 1, b: 2, c: nil)

    assert active_link?('/', a: 1)
    assert active_link?('/', b: 2)
  end
end
