# Helper methods for Credentials controller
module CredentialsHelper
  def credential_status_class(credential)
    if credential.expired?
      'danger'
    elsif credential.expiring?
      'warning'
    else
      'success'
    end
  end

  def multiple_edit_checkbox(credential)
    button_tag(bs_icon('unchecked'), class: 'row-selector btn btn-default', type: :button) +
      check_box_tag('ids[]', credential.id, false, class: 'hidden')
  end

  def credential_status_label(credential)
    dtg_span(credential.created_at, :hidden) +
      content_tag(:span, credential.status, class: "label label-#{credential_status_class(credential)}")
  end

  def ssh_key_span(key)
    key_with_spaces = key.to_s.scan(/.{1,70}/).join('&#8203;').html_safe
    content_tag :span,
                truncate(key, length: 43),
                class: 'ssh-key',
                data: { toggle: :popover, trigger: :click, content: key_with_spaces, placement: :bottom }
  end

  def key_info(key)
    content_tag(:div, id: 'key-info', class: 'help-block') do
      if Credential.key_valid? key
        content_tag(:div, class: 'text-success') do
          "#{Credential.key_bits key} Bits - MD5 fingerprint: #{Credential.key_fingerprint key}"
        end
      elsif key
        content_tag(:div, 'is not valid', class: 'text-danger')
      end
    end
  end

  def duration_left(credential)
    credential.expired? ? '&mdash;'.html_safe : time_ago_in_words(credential.expire_at)
  end

  def expiration(credential)
    dtg_span(credential.created_at, :hidden) +
      content_tag(:span, duration_left(credential), class: 'duration-left')
  end

  # def expiration_progress(credential)
  #   percentage, expire_at = credential.expiration_percentage, credential.expire_at
  #   css_class = %W(progress-bar progress-bar-#{credential_status_class(credential)})
  #   css_class << %w(progress-bar-striped active) unless credential.expired?
  #   dtg_span(expire_at, :hidden) + content_tag(:div, class: :progress) do
  #     content_tag :div, nil,
  #                 class: css_class,
  #                 style: "width: #{percentage}%",
  #                 role: :progressbar, aria: { valuenow: percentage, valuemin: 0, valuemax: 100 }
  #   end + duration_left(credential)
  # end
end
