class ImpersonationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_service_role

  def create
    account = Account.find(params[:account_id])
    session[:original_user_id] = current_user.id
    session[:impersonating_account_id] = account.id

    ActsAsTenant.current_tenant = account

    # Redirect to the subdomain
    redirect_to root_url, notice: "Now impersonating: #{account.name}"
  end

  def destroy
    session.delete(:impersonating_account_id)
    ActsAsTenant.current_tenant = nil

    # Redirect back to the original subdomain
    redirect_to root_url(subdomain: 'services'), notice: 'Stopped impersonating.'
  end

  private

  def authorize_service_role
    redirect_to root_path, alert: 'Not authorized' unless current_user.has_role?('Service')
  end
end
