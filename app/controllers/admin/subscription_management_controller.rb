class Admin::SubscriptionManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :require_platform_admin
  before_action :set_company, only: [ :show, :upgrade, :extend_trial, :cancel ]

  def index
    @pagy, @companies = pagy(Company.includes(:company_subscription, :users).order(:name), items: 20)
  end

  def show
    @subscription = @company.company_subscription
  end

  def upgrade
    duration_months = params[:duration_months]&.to_i || 1

    if @company.upgrade_to_paid_subscription(duration_months: duration_months)
      redirect_to admin_subscription_management_path(@company),
                  notice: "Subscription upgraded successfully for #{duration_months} month(s)"
    else
      redirect_to admin_subscription_management_path(@company),
                  alert: "Failed to upgrade subscription"
    end
  end

  def extend_trial
    days = params[:days]&.to_i || 30

    if @company.company_subscription
      @company.company_subscription.update!(
        end_date: @company.company_subscription.end_date + days.days
      )
      redirect_to admin_subscription_management_path(@company),
                  notice: "Trial extended by #{days} days"
    else
      redirect_to admin_subscription_management_path(@company),
                  alert: "No subscription found"
    end
  end

  def cancel
    if @company.company_subscription
      @company.company_subscription.update!(status: "expired")
      redirect_to admin_subscription_management_path(@company),
                  notice: "Subscription cancelled"
    else
      redirect_to admin_subscription_management_path(@company),
                  alert: "No subscription found"
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def require_platform_admin
    unless current_user.platform_admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end
