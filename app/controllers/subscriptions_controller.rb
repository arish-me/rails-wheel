class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_company_user!
  before_action :set_company

  def index
    @subscription = @company.active_subscription
  end

  def pricing
    @plans = SubscriptionPlan.active.ordered_by_tier
    @current_subscription = @company.active_subscription
  end

  def request_upgrade
    plan = SubscriptionPlan.find(params[:plan_id])

    # Create a subscription request (you can create a separate model for this)
    # For now, we'll just redirect to contact support
    redirect_to contact_path(
      subject: "Subscription Upgrade Request",
      message: "I would like to upgrade to #{plan.name} plan. Company: #{@company.name}, Contact: #{current_user.email}"
    ), notice: "Your upgrade request has been sent. We'll contact you soon!"
  rescue ActiveRecord::RecordNotFound
    redirect_to pricing_subscriptions_path, alert: "Please select a valid subscription plan."
  end

  def contact_support
    # This will be handled by the contact page
  end

  private

  def ensure_company_user!
    unless current_user.company_user?
      redirect_to dashboard_path, alert: "Only company users can manage subscriptions."
    end
  end

  def set_company
    @company = current_user.company
    unless @company
      redirect_to dashboard_path, alert: "Please complete your company setup first."
    end
  end
end
