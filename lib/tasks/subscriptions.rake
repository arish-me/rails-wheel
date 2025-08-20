namespace :subscriptions do
  desc "Expire expired trial subscriptions"
  task expire_trials: :environment do
    puts "Checking for expired trial subscriptions..."

    expired_count = SubscriptionService.expire_expired_trials

    if expired_count > 0
      puts "✅ Expired #{expired_count} trial subscription(s)"
    else
      puts "✅ No expired trials found"
    end
  end

  desc "Expire expired paid subscriptions"
  task expire_subscriptions: :environment do
    puts "Checking for expired paid subscriptions..."

    expired_count = SubscriptionService.expire_expired_subscriptions

    if expired_count > 0
      puts "✅ Expired #{expired_count} paid subscription(s)"
    else
      puts "✅ No expired paid subscriptions found"
    end
  end

  desc "Send expiry notifications"
  task send_expiry_notifications: :environment do
    puts "Sending subscription expiry notifications..."

    # Get subscriptions expiring in 7, 3, and 1 days
    expiring_7_days = SubscriptionService.get_expiring_soon_subscriptions(days: 7)
    expiring_3_days = SubscriptionService.get_expiring_soon_subscriptions(days: 3)
    expiring_1_day = SubscriptionService.get_expiring_soon_subscriptions(days: 1)

    total_notifications = 0

    # Send 7-day notifications
    expiring_7_days.each do |subscription|
      # Here you would send email notifications
      puts "📧 7-day expiry notification for #{subscription.company.name}"
      total_notifications += 1
    end

    # Send 3-day notifications
    expiring_3_days.each do |subscription|
      puts "📧 3-day expiry notification for #{subscription.company.name}"
      total_notifications += 1
    end

    # Send 1-day notifications
    expiring_1_day.each do |subscription|
      puts "📧 1-day expiry notification for #{subscription.company.name}"
      total_notifications += 1
    end

    puts "✅ Sent #{total_notifications} expiry notifications"
  end

  desc "Create trial subscription for existing companies without subscription"
  task create_missing_trials: :environment do
    puts "Creating trial subscriptions for companies without subscriptions..."

    companies_without_subscription = Company.left_joins(:company_subscriptions)
                                           .where(company_subscriptions: { id: nil })

    created_count = 0

    companies_without_subscription.each do |company|
      if SubscriptionService.create_trial_subscription(company)
        created_count += 1
        puts "✅ Created trial subscription for #{company.name}"
      else
        puts "❌ Failed to create trial subscription for #{company.name}"
      end
    end

    puts "✅ Created #{created_count} trial subscription(s)"
  end

  desc "Show subscription statistics"
  task stats: :environment do
    puts "📊 Subscription Statistics"
    puts "=" * 50

    total_companies = Company.count
    companies_with_subscription = Company.joins(:company_subscriptions).distinct.count
    companies_without_subscription = total_companies - companies_with_subscription

    puts "Total Companies: #{total_companies}"
    puts "Companies with Subscription: #{companies_with_subscription}"
    puts "Companies without Subscription: #{companies_without_subscription}"
    puts ""

    # Subscription status breakdown
    trial_count = CompanySubscription.trial.count
    active_count = CompanySubscription.active.count
    expired_count = CompanySubscription.expired.count
    canceled_count = CompanySubscription.canceled.count

    puts "Subscription Status Breakdown:"
    puts "- Trial: #{trial_count}"
    puts "- Active: #{active_count}"
    puts "- Expired: #{expired_count}"
    puts "- Canceled: #{canceled_count}"
    puts ""

    # Plan breakdown
    SubscriptionPlan.active.each do |plan|
      plan_count = CompanySubscription.joins(:subscription_plan)
                                     .where(subscription_plans: { id: plan.id })
                                     .count
      puts "#{plan.name}: #{plan_count} subscriptions"
    end
  end
end
