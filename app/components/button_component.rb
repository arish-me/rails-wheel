# frozen_string_literal: true

# <!-- Danger button with right-aligned icon -->
# <%= render(ButtonComponent.new(
#   label: "Delete",
#   variant: :danger,
#   icon: "trash",
#   icon_position: :right,
#   confirm: "Are you sure you want to delete this?"
# )) %>

# <!-- Full width secondary button -->
# <%= render(ButtonComponent.new(
#   label: "Cancel",
#   variant: :secondary,
#   full_width: true
# )) %>

# <!-- Extra small info button -->
# <%= render(ButtonComponent.new(
#   label: "Info",
#   variant: :info,
#   size: :xs
# )) %>

class ButtonComponent < ViewComponent::Base
  VARIANTS = {
    default: "btn--primary",
    primary: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-300",
    secondary: "bg-gray-200 text-gray-800 hover:bg-gray-300 focus:ring-gray-200",
    success: "bg-green-600 text-white hover:bg-green-700 focus:ring-green-300",
    danger: "bg-red-600 text-white hover:bg-red-700 focus:ring-red-300",
    warning: "bg-yellow-500 text-white hover:bg-yellow-600 focus:ring-yellow-300",
    info: "bg-indigo-600 text-white hover:bg-indigo-700 focus:ring-indigo-300"
  }.freeze

  SIZES = {
    xs: "text-xs px-2 py-1",
    sm: "text-sm px-3 py-1.5",
    md: "text-sm px-4 py-2",
    lg: "text-base px-5 py-2.5",
    xl: "text-base px-6 py-3"
  }.freeze

  def initialize(
    label: nil,
    variant: :primary,
    size: :md,
    icon: nil,
    icon_position: :left,
    href: nil,
    method: :get,
    type: nil,  # Add this line
    turbo_frame: nil,
    turbo_stream: nil,
    confirm: nil,
    disabled: false,
    full_width: false,
    class_name: "",
    data: {}
  )
    @label = label
    @variant = VARIANTS.fetch(variant.to_sym, VARIANTS[:primary])
    @size = SIZES.fetch(size.to_sym, SIZES[:md])
    @icon = icon
    @icon_position = icon_position
    @href = href
    @method = method
    @type = type  # Add this line
    @turbo_frame = turbo_frame
    @turbo_stream = turbo_stream
    @confirm = confirm
    @disabled = disabled
    @full_width = full_width
    @class_name = class_name
    @data = data
  end

  def button_classes
    [
      "btn rounded-lg font-medium inline-flex items-center gap-1.5 transition-colors focus:ring-4",
      @variant,
      @size,
      @full_width ? "w-full justify-center" : "",
      @disabled ? "opacity-60 cursor-not-allowed" : "",
      @class_name
    ].join(" ").strip
  end

  def button_data
    data = @data || {}
    data[:turbo_frame] = @turbo_frame if @turbo_frame
    data[:turbo_stream] = @turbo_stream if @turbo_stream
    data[:confirm] = @confirm if @confirm
    data
  end

  def render_icon
    return unless @icon

    icon_class = "w-4 h-4"
    if helpers.respond_to?(:lucide_icon)
      helpers.lucide_icon(@icon, class: icon_class)
    else
      content_tag(:i, "", class: "#{@icon} #{icon_class}")
    end
  end
end
