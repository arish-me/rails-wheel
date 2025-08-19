class Admin::SubscriptionManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_platform_admin!
  before_action :set_company, only: [:show, :update_subscription, :cancel_subscription, :extend_trial]

  def index
    @companies = Company.includes(:active_subscription, :subscription_plan)
                       .order(created_at: :desc)
                       .page(params[:page])
    
    @subscription_plans = SubscriptionPlan.active.ordered_by_tier
    
    # Filter by subscription status
    @status_filter = params[:status]
    if @status_filter.present?
      case @status_filter
      when 'trial'
        @companies = @companies.joins(:company_subscriptions).where(company_subscriptions: { status: 'trial' })
      when 'active'
        @companies = @companies.joins(:company_subscriptions).where(company_subscriptions: { status: 'active' })
      when 'expired'
        @companies = @companies.joins(:company_subscriptions).where(company_subscriptions: { status: 'expired' })
      when 'no_subscription'
        @companies = @companies.left_joins(:company_subscriptions).where(company_subscriptions: { id: nil })
      end
    end
  end

  def show
    @subscription = @company.active_subscription
    @subscription_history = @company.company_subscriptions.includes(:subscription_plan)
                                   .order(created_at: :desc)
    @subscription_plans = SubscriptionPlan.active.ordered_by_tier
  end

  def update_subscription
    plan_name = params[:plan_name]
    duration_months = params[:duration_months]&.to_i || 1
    notes = params[:notes]
    
    if SubscriptionService.upgrade_company_subscription(@company, plan_name, duration_months: duration_months)
      # Log the change
      @company.company_subscriptions.last.update(
        admin_notes: notes,
        updated_by_admin: current_user.id,
        updated_at: Time.current
      )
      
      redirect_to admin_subscription_management_path(@company), 
                  notice: "Successfully updated #{@company.name} to #{plan_name} for #{duration_months} month(s)"
    else
      redirect_to admin_subscription_management_path(@company), 
                  alert: "Failed to update subscription"
    end
  end

  def cancel_subscription
    subscription = @company.active_subscription
    notes = params[:notes]
    
    if subscription&.cancel_subscription
      subscription.update(
        admin_notes: notes,
        updated_by_admin: current_user.id,
        updated_at: Time.current
      )
      
      redirect_to admin_subscription_management_path(@company), 
                  notice: "Successfully canceled subscription for #{@company.name}"
    else
      redirect_to admin_subscription_management_path(@company), 
                  alert: "Failed to cancel subscription"
    end
  end

  def extend_trial
    days = params[:days].to_i
    notes = params[:notes]
    
    subscription = @company.active_subscription
    
    if subscription&.trial?
      new_end_date = subscription.trial_end + days.days
      subscription.update(
        trial_end: new_end_date,
        admin_notes: notes,
        updated_by_admin: current_user.id,
        updated_at: Time.current
      )
      
      redirect_to admin_subscription_management_path(@company), 
                  notice: "Successfully extended trial by #{days} days for #{@company.name}"
    else
      redirect_to admin_subscription_management_path(@company), 
                  alert: "Can only extend trial for companies in trial period"
    end
  end

  def extend_subscription
    days = params[:days].to_i
    notes = params[:notes]
    
    subscription = @company.active_subscription
    
    if subscription&.active?
      if subscription.extend_subscription(days)
        subscription.update(
          admin_notes: notes,
          updated_by_admin: current_user.id,
          updated_at: Time.current
        )
        
        redirect_to admin_subscription_management_path(@company), 
                    notice: "Successfully extended subscription by #{days} days for #{@company.name}"
      else
        redirect_to admin_subscription_management_path(@company), 
                    alert: "Failed to extend subscription"
      end
    else
      redirect_to admin_subscription_management_path(@company), 
                  alert: "Can only extend active subscriptions"
    end
  end

  def renew_subscription
    duration_months = params[:duration_months]&.to_i || 1
    notes = params[:notes]
    
    subscription = @company.active_subscription
    
    if subscription&.active? || subscription&.expired?
      if subscription.renew_subscription(duration_months: duration_months)
        subscription.update(
          admin_notes: notes,
          updated_by_admin: current_user.id,
          updated_at: Time.current
        )
        
        redirect_to admin_subscription_management_path(@company), 
                    notice: "Successfully renewed subscription for #{duration_months} month(s) for #{@company.name}"
      else
        redirect_to admin_subscription_management_path(@company), 
                    alert: "Failed to renew subscription"
      end
    else
      redirect_to admin_subscription_management_path(@company), 
                  alert: "Can only renew active or expired subscriptions"
    end
  end

  def create_trial
    notes = params[:notes]
    
    if SubscriptionService.create_trial_subscription(@company)
      @company.company_subscriptions.last.update(
        admin_notes: notes,
        updated_by_admin: current_user.id,
        updated_at: Time.current
      )
      
      redirect_to admin_subscription_management_path(@company), 
                  notice: "Successfully created trial subscription for #{@company.name}"
    else
      redirect_to admin_subscription_management_path(@company), 
                  alert: "Failed to create trial subscription"
    end
  end

  def bulk_actions
    action = params[:bulk_action]
    company_ids = params[:company_ids] || []
    plan_name = params[:plan_name]
    notes = params[:notes]
    
    companies = Company.where(id: company_ids)
    success_count = 0
    
    companies.each do |company|
      case action
      when 'upgrade'
        if SubscriptionService.upgrade_company_subscription(company, plan_name)
          company.company_subscriptions.last.update(
            admin_notes: notes,
            updated_by_admin: current_user.id,
            updated_at: Time.current
          )
          success_count += 1
        end
      when 'cancel'
        subscription = company.active_subscription
        if subscription&.cancel_subscription
          subscription.update(
            admin_notes: notes,
            updated_by_admin: current_user.id,
            updated_at: Time.current
          )
          success_count += 1
        end
      when 'create_trial'
        if SubscriptionService.create_trial_subscription(company)
          company.company_subscriptions.last.update(
            admin_notes: notes,
            updated_by_admin: current_user.id,
            updated_at: Time.current
          )
          success_count += 1
        end
      end
    end
    
    redirect_to admin_subscription_management_index_path, 
                notice: "Successfully processed #{success_count} out of #{companies.count} companies"
  end

  private

  def ensure_platform_admin!
    unless current_user.platform_admin?
      redirect_to dashboard_path, alert: 'Access denied. Platform admin privileges required.'
    end
  end

  def set_company
    @company = Company.find(params[:id])
  end
end
