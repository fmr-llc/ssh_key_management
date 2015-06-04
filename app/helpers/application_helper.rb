# Global helper methods for all controller
module ApplicationHelper
  include BootstrapHelper

  SHOW_LINK_IN_CRUD = false
  ICON_ONLY = true
  local_env = Rails.env.development? || Rails.env.test?
  REVISIONS_LOG = Rails.root.join(local_env ? 'test/fixtures' : '../..', 'revisions.log')

  def action_btns_for(object)
    content_tag(:div, copy_button_for(object, 'btn btn-info'), class: 'btn-group') +
      '&nbsp;'.html_safe +
      crud_btns_for(object)
  end

  def crud_btns_for(object, group = true)
    css_class = 'btn-group' if group
    content_tag :div, class: css_class do
      concat show_link_for(object, 'btn btn-default') if SHOW_LINK_IN_CRUD
      concat edit_link_for(object, 'btn btn-default')
      concat destroy_link_for(object, 'btn btn-danger')
    end
  end

  def field_with_value(field_name, value, size = 'md')
    content_tag :div, class: :row do
      concat content_tag(:div, content_tag(:strong, field_name), class: "col-#{size}-2 text-right")
      concat content_tag(:div, value, class: "col-#{size}-4")
    end
  end

  def crud_dropdown_btn_for(object, css_classes = nil)
    content_tag :div, class: [*css_classes].push(:dropdown) do
      bs_dropdown_button_with_text + content_tag(:ul, class: 'dropdown-menu dropdown-menu-right') do
        concat content_tag(:li, show_link_for(object)) if SHOW_LINK_IN_CRUD
        concat content_tag(:li, edit_link_for(object))
        concat content_tag(:li, destroy_link_for(object, 'bg-danger'))
      end
    end
  end

  def show_link_for(object, css_class = nil)
    text = ICON_ONLY ? nil : t(:'helpers.links.show', default: 'Show')
    link_to bs_icon_and_text('sunglasses', text),
            object,
            remote: true,
            class:  [*css_class].push('show-link')
  end

  def copy_button_for(object, css_class = nil)
    return nil unless object.respond_to?(:copy_text_attr)
    name  = object.class.human_attribute_name object.copy_text_attr
    button_tag bs_icon_and_text('copy', ICON_ONLY ? nil : t(:'helpers.links.copy', default: 'Copy')),
               data: {
                 clipboard_text: object[object.copy_text_attr],
                 copied_hint: "Copied #{name}!",
                 copy_hint: "Copy #{name} to clipboard"
               },
               type: :button,
               class: [*css_class].push('copy-link')
  end

  def edit_link_for(object, css_class = nil)
    text = ICON_ONLY ? nil : t(:'helpers.links.edit', default: 'Edit')
    link_to bs_icon_and_text('pencil', text),
            [:edit, object],
            remote: true,
            class: [*css_class].push('edit-link')
  end

  def destroy_link_for(object, css_class = nil)
    text = ICON_ONLY ? nil : t(:'helpers.links.destroy', default: 'Destroy')
    link_to bs_icon_and_text('trash', text),
            object,
            method: :delete,
            remote: true,
            class:  [*css_class].push('destroy-link'),
            data: { confirm: 'Are you sure?' }
  end

  def mail_to_user(user)
    mail_to(user.email, user.full_name)
  end

  def dtg_span(time, css_class = [])
    content_tag :span,
                time,
                class: [*css_class] << 'datetimegroup',
                data: {
                  order: time.to_i,
                  time: time.iso8601
                }
  end

  def gravatar(user, size = 40)
    image_tag "https://secure.gravatar.com/avatar/#{user.gravatar_hash}?s=#{size}&d=mm&r=g"
  end

  def capistrano_deployment_revision
    return unless File.exist? REVISIONS_LOG
    # eg "Branch master (at 820516a) deployed as release 20150513185431 by jenkins"
    message = IO.readlines(REVISIONS_LOG)[-1]
    branch, tags, release = message.split(/^Branch (.+?) \(at (.+?)\) deployed as release (\d+?) .+$/)[1..-1]
    release = Time.utc(*release.split(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/)[1..-1])
    [
      bold_field('Branch: ', branch),
      bold_field('Tags: ', tags),
      bold_field('Release: ', release)
    ].join(' / ').html_safe
  end

  def bold_field(field, value)
    content_tag(:span, content_tag(:b, field) + value)
  end
end
