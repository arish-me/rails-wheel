class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization
  impersonates :user
  # Rescue unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale_from_session_or_params

  # Locale switcher action - uses Turbo to avoid page reload
  def set_locale
    locale = params[:locale].to_sym
    if I18n.available_locales.include?(locale)
      session[:locale] = locale
      I18n.locale = locale
    end

    respond_to do |format|
      # format.turbo_stream {
      #   render turbo_stream: turbo_stream.replace('content', partial: 'shared/content')
      # }
      format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def set_locale_from_session_or_params
    I18n.locale = if session[:locale].present? && I18n.available_locales.include?(session[:locale].to_sym)
                    session[:locale].to_sym
                  else
                    I18n.default_locale
                  end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
