# frozen_string_literal: true

# An extension to `button_to` helper.  All options are passed through to the `button_to` helper with some additional
# options available.
class ButtonComponent < ButtonishComponent
  attr_reader :confirm

  def initialize(confirm: nil, **)
    super(**)
    @confirm = confirm
  end

  def container(&)
    if href.present?
      button_to(href, **merged_opts, &)
    else
      content_tag(:button, **merged_opts, &)
    end
  end

  private

  def merged_opts
    merged_opts = opts.dup || {}
    extra_classes = merged_opts.delete(:class)
    merged_opts.delete(:href)
    data = merged_opts.delete(:data) || {}

    data = data.merge(turbo_confirm: confirm.to_data_attribute) if confirm.present?

    data = data.merge(turbo_frame: frame) if frame.present?

    merged_opts.merge(
      class: class_names(container_classes, extra_classes),
      data: data
    )
  end
end
