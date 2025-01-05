class ApplicationController < ActionController::Base
  set_current_tenant_by_subdomain(:account, :subdomain)
  before_action :set_current_tenant
  include Pagy::Backend
  include Pundit::Authorization
  impersonates :user
  # Rescue unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :ensure_tenant_exists

 #prepend_before_action :find_tenant_by_subdomain if :devise_controller?

  def ensure_tenant_exists
    if ActsAsTenant.current_tenant.nil?
      # Render 404 page if no tenant matches the subdomain
      render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
    end
  end

  def set_current_tenant
    return unless current_user && current_user.has_role?('Service')

    if session[:impersonating_account_id]
      ActsAsTenant.current_tenant = Account.find(session[:impersonating_account_id])
    else
      ActsAsTenant.current_tenant = current_user&.account
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
