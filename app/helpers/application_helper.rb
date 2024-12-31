module ApplicationHelper
  include Pagy::Frontend

  def render_flash_notifications
    notifications = flash.flat_map do |type, message_or_messages|
      Array(message_or_messages).map do |message|
        render partial: "shared/notification", locals: { type: type, message: message }
      end
    end

    safe_join(notifications)
  end

  def modal(options = {}, &block)
    content = capture &block
    render partial: "shared/modal", locals: { content:, classes: options[:classes] }
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
end
