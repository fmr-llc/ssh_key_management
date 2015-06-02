# Bootstrap helper methods
module BootstrapHelper
  def bs_icon(icon)
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}", 'aria-hidden' => true)
  end

  def bs_icon_and_text(icon, text = nil)
    if text
      content_tag :span, class: 'icon-with-text' do
        bs_icon(icon) + text
      end
    else
      bs_icon(icon) + text
    end
  end

  def bs_labels_for_tags(tags)
    content_tag :div, class: 'tag-list' do
      tags.each do |tag|
        concat content_tag(:span, tag, class: 'label label-default')
      end
    end
  end

  def bs_alert(kind = 'success', columns = 4, &block)
    kind = 'success' unless %w(success info warning danger).include?(kind)
    columns = 12 if columns < 0 || columns > 12
    css_alert_classes = "alert alert-#{kind} alert-dismissible"
    css_text_classes  = 'text-info text-center'
    css_col_classes   = "col-md-#{columns} col-md-offset-#{(12 - columns) / 2}"

    content_tag(:div, class: [css_alert_classes, css_text_classes, css_col_classes]) do
      content_tag(:button, type: :button, class: :close, 'data-dismiss' => :alert) do
        content_tag(:span, '&times;'.html_safe)
      end + content_tag(:div, capture(&block))
    end
  end

  def bs_dropdown_button_with_text(text = nil, button_type = 'default')
    button_text = text ? content_tag(:span, text + ' ') : ''
    content_tag(:button, class: "btn btn-#{button_type} dropdown-toggle",  data: { toggle: :dropdown }) do
      button_text + content_tag(:span, nil, class: :caret)
    end
  end

  def bs_nav_link_to(link_text, link_path, options = nil)
    css_class = [*options.delete(:css_class)]
    active_class = 'active' if active_link? link_path, options[:active]
    content_tag :li, class: [*css_class].push(active_class) do
      link_to link_text, link_path
    end
  end

  private

  def active_link?(original_url, condition = nil)
    url = URI.parse(original_url).path
    case condition
    when :inclusive, nil then !request.fullpath.match(%r{^#{Regexp.escape(url).chomp('/')}(\/.*|\?.*)?$}).blank?
    when :exclusive then !request.fullpath.match(%r{^#{Regexp.escape(url)}\/?(\?.*)?$}).blank?
    when :exact then request.fullpath == original_url
    when Regexp then !request.fullpath.match(condition).blank?
    when TrueClass then true
    when FalseClass then false
    when Hash then condition.all? { |k, v| params[k].to_s.eql? v.to_s }
    end
  end
end
