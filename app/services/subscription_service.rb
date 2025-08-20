class SubscriptionService
  def self.create_trial_subscription(company)
    # Don't create if company already has any subscription
    return company.active_subscription if company.company_subscriptions.exists?

    # Find the bronze plan (default trial plan)
    bronze_plan = SubscriptionPlan.find_by(tier: "bronze")

    return false unless bronze_plan

    # Create trial subscription
    subscription = company.company_subscriptions.create!(
      subscription_plan: bronze_plan,
      status: "trial",
      trial_start: Time.current,
      trial_end: Time.current + bronze_plan.trial_days.days
    )

    # Update company trial end date
    company.update(trial_ends_at: subscription.trial_end)

    subscription
  end

  def self.expire_expired_trials
    expired_subscriptions = CompanySubscription.trial.where("trial_end <= ?", Time.current)

    expired_subscriptions.each do |subscription|
      subscription.update(status: "expired")
    end

    expired_subscriptions.count
  end

  def self.expire_expired_subscriptions
    expired_subscriptions = CompanySubscription.active.where("expires_at <= ?", Time.current)

    expired_subscriptions.each do |subscription|
      subscription.update(status: "expired")
    end

    expired_subscriptions.count
  end

  def self.get_expiring_soon_subscriptions(days: 30)
    CompanySubscription.active.where("expires_at <= ? AND expires_at > ?", days.days.from_now, Time.current)
  end

  def self.upgrade_company_subscription(company, plan_name, duration_months: 1)
    plan = SubscriptionPlan.find_by(name: plan_name)
    return false unless plan

    # Cancel current subscription if exists
    company.company_subscriptions.active.update_all(status: "canceled")

    # Create new subscription with expiry date
    subscription = company.company_subscriptions.create!(
      subscription_plan: plan,
      status: "active",
      expires_at: Time.current + duration_months.months
    )

    subscription
  end

  def self.check_company_limits(company)
    subscription = company.active_subscription

    return {
      can_post_jobs: true,
      can_search_candidates: true,
      job_posting_limit: nil,
      candidate_search_limit: nil,
      current_job_count: company.jobs.count,
      current_search_count: 0 # This would need to be tracked separately
    } unless subscription

    {
      can_post_jobs: subscription.can_post_jobs?,
      can_search_candidates: subscription.can_search_candidates?,
      job_posting_limit: subscription.subscription_plan.job_posting_limit,
      candidate_search_limit: subscription.subscription_plan.candidate_search_limit,
      current_job_count: company.jobs.count,
      current_search_count: 0 # This would need to be tracked separately
    }
  end
end
