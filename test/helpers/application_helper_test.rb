require 'test_helper'

# tests for ApplicationHelper methods
class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "should return with BS icon" do
    @output_buffer = bs_icon('asterisk')
    assert_select "span.glyphicon.glyphicon-asterisk"
  end

  test "should return span with icon and text" do
    @output_buffer = bs_icon_and_text('pencil', 'Edit me!')
    assert_select "span.icon-with-text", 'Edit me!' do
      assert_select "span.glyphicon.glyphicon-pencil", ''
    end
  end

  test "should return span with icon only if text is nil" do
    @output_buffer = bs_icon_and_text('lock')
    assert_select "span.icon-with-text", 0
    assert_select "span.glyphicon.glyphicon-lock", ''
  end

  test "should return a button group of CRUD actions" do
    object = build_stubbed :alice_credential
    @output_buffer = crud_btns_for(object)
    assert_select 'div.btn-group' do
      if SHOW_LINK_IN_CRUD
        assert_select 'a.btn.btn-default', 2
        assert_select 'a.btn.btn-default', ''
      else
        assert_select 'a.btn.btn-default', 1
      end
      assert_select 'a.btn.btn-default', ''
      assert_select 'a.btn.btn-danger', ''
    end
    @output_buffer = crud_btns_for(object, false)
    assert_select 'div:not([class])', 1
  end

  test "should return a div row for a field/value" do
    field = "Meal"
    value = "Oatmeal with Fries"
    @output_buffer = field_with_value(field, value)
    assert_select "div.row" do
      assert_select "div.col-md-2.text-right" do
        assert_select "strong", "Meal"
      end
      assert_select "div.col-md-4", "Oatmeal with Fries"
    end
    @output_buffer = field_with_value(field, value, 'xs')
    assert_select "div.row" do
      assert_select "div.col-xs-2.text-right", 1
      assert_select "div.col-xs-4", 1
    end
  end

  test "should return a dropdown with action buttons for object" do
    object = build_stubbed :alice_credential
    @output_buffer = crud_dropdown_btn_for(object)
    assert_select 'div.dropdown' do
      assert_select "ul.dropdown-menu.dropdown-menu-right" do
        if SHOW_LINK_IN_CRUD
          assert_select 'li:not([class])', 3
        else
          assert_select 'li:not([class])', 2
        end
        assert_select 'li' do
          assert_select "a[href='#{url_for [:edit, object]}']", ''
        end
        assert_select 'li' do
          assert_select "a.bg-danger[href='#{url_for object}'][data-method='delete']", ''
        end
      end
    end
    @output_buffer = crud_dropdown_btn_for(object, 'bg-primary')
    assert_select 'div.dropdown.bg-primary', 1
  end

  test "should return a dropdown button" do
    @output_buffer = bs_dropdown_button_with_text("Click me!")
    assert_select 'button.btn.btn-default.dropdown-toggle[data-toggle="dropdown"]' do
      assert_select 'span:not([class])', 1
      assert_select 'span:not([class])', "Click me!"
      assert_select 'span.caret', 1
      assert_select 'span.caret', ''
    end
    @output_buffer = bs_dropdown_button_with_text('', 'primary')
    assert_select 'button.btn.btn-primary.dropdown-toggle[data-toggle="dropdown"]' do
      assert_select 'span:not([class])', 1
      assert_select 'span:not([class])', ''
      assert_select 'span.caret', 1
      assert_select 'span.caret', ''
    end
    @output_buffer = bs_dropdown_button_with_text('Dangerous actions', 'danger')
    assert_select 'button.btn.btn-danger.dropdown-toggle[data-toggle="dropdown"]' do
      assert_select 'span:not([class])', 1
      assert_select 'span:not([class])', 'Dangerous actions'
      assert_select 'span.caret', 1
      assert_select 'span.caret', ''
    end
  end

  test "should return proper show link" do
    object = build_stubbed :alice_credential
    show_path = url_for object
    @output_buffer = show_link_for(object, 'my-class')
    assert_select "a.my-class.show-link[href='#{show_path}'][data-remote='true']" do
      assert_select "span.glyphicon.glyphicon-sunglasses", ''
    end
    @output_buffer = show_link_for(object)
    assert_select "a.show-link[href='#{show_path}'][data-remote='true']", 1
  end

  test "should return proper edit link" do
    object = build_stubbed :alice_credential
    edit_path = url_for [:edit, object]
    @output_buffer = edit_link_for(object, 'edit-link-class')
    assert_select "a.edit-link-class.edit-link[href='#{edit_path}'][data-remote='true']" do
      assert_select "span.glyphicon.glyphicon-pencil", ''
    end
    @output_buffer = edit_link_for(object)
    assert_select "a.edit-link[href='#{edit_path}'][data-remote='true']", 1
  end

  test "should return proper destroy link" do
    object = build_stubbed :alice_credential
    destroy_path = url_for object
    @output_buffer = destroy_link_for(object, 'peligro')
    assert_select "a.peligro.destroy-link[href='#{destroy_path}'][data-remote='true'][data-method='delete'][data-confirm='Are you sure?']" do
      assert_select "span.glyphicon.glyphicon-trash", ''
    end
    @output_buffer = destroy_link_for(object)
    assert_select "a.destroy-link[href='#{destroy_path}'][data-remote='true'][data-method='delete'][data-confirm='Are you sure?']", 1
  end

  test "should create a mail_to link" do
    user = build_stubbed :alice
    @output_buffer = mail_to_user user
    assert_select "a:not([class])[href='mailto:#{user.email}']", user.full_name
  end

  test "should return a BS alert message" do
    @output_buffer = bs_alert { 'Message 1' }
    assert_select "div.alert.alert-success.alert-dismissible.text-info.text-center.col-md-4.col-md-offset-4" do
      assert_select "button.close[data-dismiss='alert'][type='button']" do
        assert_select 'span', "×" unless defined? JRUBY_VERSION # XXX weird nokogiri entity problem
      end
      assert_select 'div:not([class])', 'Message 1'
    end
    @output_buffer = bs_alert('info', 6) { content_tag(:div, 'Message 2', class: 'inner-message') }
    assert_select "div.alert.alert-info.alert-dismissible.text-info.text-center.col-md-6.col-md-offset-3" do
      assert_select "button.close[data-dismiss='alert'][type='button']" do
        assert_select 'span', "×" unless defined? JRUBY_VERSION # XXX weird nokogiri entity problem
      end
      assert_select 'div:not([class])' do
        assert_select 'div.inner-message', 'Message 2'
      end
    end
    @output_buffer = bs_alert('bad-type', 22) { 'Message 3' }
    assert_select "div.alert.alert-success.alert-success.text-info.text-center.col-md-12.col-md-offset-0" do
      assert_select "button.close[data-dismiss='alert'][type='button']" do
        assert_select 'span', "×" unless defined? JRUBY_VERSION # XXX weird nokogiri entity problem
      end
      assert_select 'div:not([class])', 'Message 3'
    end
  end

  test "should return a date time group span" do
    t = Time.zone.now
    @output_buffer = dtg_span(t)
    assert_select "span.datetimegroup[data-order='#{t.to_i}'][data-time='#{t.iso8601}']", t.to_s
  end

  test "should return labels for tags" do
    tags = %w(tag1 tag2 tag3)
    @output_buffer = bs_labels_for_tags tags
    assert_select 'div.tag-list' do
      assert_select 'span.label.label-default', text: 'tag1'
      assert_select 'span.label.label-default', text: 'tag2'
      assert_select 'span.label.label-default', text: 'tag3'
    end
  end

  test 'should return a formatted revision line' do
    @output_buffer = capistrano_deployment_revision
    assert_select 'span', text: 'Branch: master'
    assert_select 'span' do
      assert_select 'b', 'Branch:'
    end
    assert_select 'span', text: 'Tags: 820516a'
    assert_select 'span' do
      assert_select 'b', 'Tags:'
    end
    assert_select 'span', text: 'Release: 2015-05-13 18:54:31 UTC'
    assert_select 'span' do
      assert_select 'b', 'Release:'
    end
  end
end
