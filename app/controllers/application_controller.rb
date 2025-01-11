class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization
  impersonates :user

  before_action :set_current_tenant
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_current_tenant
    subdomain = request.subdomain

    # Skip tenant setup for non-subdomain routes
    return if subdomain.blank?

    # Find Account or Site by subdomain
    account = Account.find_by(subdomain: subdomain)
    site = Site.find_by(subdomain: subdomain)

    if account.present?
      ActsAsTenant.current_tenant = account
    elsif site.present?
      ActsAsTenant.current_tenant = site.account # Associate site with its tenant account
    else
      render_not_found
    end
  end

  private

  def render_not_found
    render file: Rails.root.join("public", "404.html"), status: :not_found, layout: false
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
