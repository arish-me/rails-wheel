class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  # Rescue unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
