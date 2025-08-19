class Admin::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_company, only: [:show, :upgrade, :cancel]

  def index
    @subscriptions = CompanySubscription.includes(:company, :subscription_plan)
                                      .order(created_at: :desc)
                                      .page(params[:page])
  end

  def show
    @subscription = @company.active_subscription
    @subscription_history = @company.company_subscriptions.includes(:subscription_plan)
                                   .order(created_at: :desc)
  end

  def upgrade
    plan_name = params[:plan_name]
    
    if SubscriptionService.upgrade_company_subscription(@company, plan_name)
      redirect_to admin_subscription_path(@company), notice: "Successfully upgraded #{@company.name} to #{plan_name}"
    else
      redirect_to admin_subscription_path(@company), alert: "Failed to upgrade subscription"
    end
  end

  def cancel
    subscription = @company.active_subscription
    
    if subscription&.cancel_subscription
      redirect_to admin_subscription_path(@company), notice: "Successfully canceled subscription for #{@company.name}"
    else
      redirect_to admin_subscription_path(@company), alert: "Failed to cancel subscription"
    end
  end

  private

  def ensure_admin!
    unless current_user.platform_admin?
      redirect_to dashboard_path, alert: 'Access denied. Admin privileges required.'
    end
  end

  def set_company
    @company = Company.find(params[:id])
  end
end
