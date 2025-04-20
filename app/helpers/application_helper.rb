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

  def render_flash_notifications
    notifications = flash.flat_map do |type, message_or_messages|
      Array(message_or_messages).map do |message|
        render partial: "shared/notification", locals: { type: type, message: message }
      end
    end

    safe_join(notifications)
  end

  def impersonating?
    current_user != true_user
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

  def can?(action, resource)
    policy(resource).public_send("#{action}?")
  end
end
