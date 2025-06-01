module ApplicationHelper
  include Pagy::Frontend

  # Return a human-readable name for the given locale
  def locale_name(locale)
    case locale.to_sym
    when :en
      "English"
    when :es
      "Español"
    when :fr
      "Français"
    else
      locale.to_s.upcase
    end
  end

  def previous_path
    session[:return_to] || fallback_path
  end

  def fallback_path
    root_path
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def header_title(page_title)
    content_for(:header_title) { page_title }
  end

  def icon(key, size: "md", color: "default", custom: false, as_button: false, **opts)
    extra_classes = opts.delete(:class)
    sizes = { xs: "w-3 h-3", sm: "w-4 h-4", md: "w-5 h-5", lg: "w-6 h-6", xl: "w-7 h-7", "2xl": "w-8 h-8" }
    colors = { default: "fg-gray", white: "fg-inverse", success: "text-success", warning: "text-warning", destructive: "text-destructive", current: "text-current" }

    icon_classes = class_names(
      "shrink-0",
      sizes[size.to_sym],
      colors[color.to_sym],
      extra_classes
    )

    if custom
      inline_svg_tag("#{key}.svg", class: icon_classes, **opts)
    elsif as_button
      render ButtonComponent.new(variant: "icon", class: extra_classes, icon: key, size: size, type: "button", **opts)
    else
      lucide_icon(key, class: icon_classes, **opts)
    end
  end

  def impersonating?
    current_user != true_user
  end

  def page_active?(path)
    current_page?(path) || (request.path.start_with?(path) && path != "/")
  end

  def modal(options = {}, &block)
    content = capture &block
    render partial: "shared/modal", locals: { content:, classes: options[:classes] }
  end

  def drawer(reload_on_close: false, &block)
    content = capture &block
    render partial: "shared/drawer", locals: { content:, reload_on_close: }
  end


  def custom_pagy_url_for(pagy, page, current_path: nil)
    if current_path.blank?
      pagy_url_for(pagy, page)
    else
      uri = URI.parse(current_path)
      params = URI.decode_www_form(uri.query || "").to_h

      # Delete existing page param if it exists
      params.delete("page")
      # Add new page param unless it's page 1
      params["page"] = page unless page == 1

      if params.empty?
        uri.path
      else
        "#{uri.path}?#{URI.encode_www_form(params)}"
      end
    end
  end

  def can?(action, record_or_class, policy_class: nil)
    actual_policy = policy_class ? policy_class.new(current_user, record_or_class) : policy(record_or_class)
    actual_policy.public_send("#{action}?")
  rescue Pundit::NotAuthorizedError
    false
  end
end
