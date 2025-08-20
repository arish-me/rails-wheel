namespace :subscriptions do
  desc "Expire expired trials"
  task expire_trials: :environment do
    puts "Checking for expired trials..."
    
    expired_trials = CompanySubscription.trial.where('end_date <= ?', Time.current)
    
    if expired_trials.any?
      expired_trials.update_all(status: 'expired')
      puts "Expired #{expired_trials.count} trial(s)"
    else
      puts "No expired trials found"
    end
  end

  desc "Check subscription status for all companies"
  task status: :environment do
    puts "Subscription Status Report"
    puts "=" * 50
    
    Company.includes(:company_subscription).find_each do |company|
      status = company.subscription_status
      subscription = company.company_subscription
      
      if subscription
        days_remaining = subscription.days_remaining
        puts "#{company.name}: #{status} (#{days_remaining} days remaining)"
      else
        puts "#{company.name}: no_subscription"
      end
    end
  end

  desc "Send expiry notifications"
  task send_expiry_notifications: :environment do
    puts "Checking for subscriptions expiring soon..."
    
    expiring_subscriptions = CompanySubscription.active.where('end_date <= ? AND end_date > ?', 7.days.from_now, Time.current)
    
    expiring_subscriptions.each do |subscription|
      company = subscription.company
      days_remaining = subscription.days_remaining
      
      puts "Company: #{company.name}, Days remaining: #{days_remaining}"
      # Here you would send actual notifications
      # UserNotifier.with(record: company, message: "Your subscription expires in #{days_remaining} days").deliver(company.users)
    end
    
    puts "Processed #{expiring_subscriptions.count} expiring subscription(s)"
  end

  desc "Create missing trials for companies without subscriptions"
  task create_missing_trials: :environment do
    puts "Creating missing trials..."
    
    companies_without_subscriptions = Company.left_joins(:company_subscription).where(company_subscriptions: { id: nil })
    
    if companies_without_subscriptions.any?
      companies_without_subscriptions.each do |company|
        company.create_trial_subscription
        puts "Created trial for #{company.name}"
      end
      puts "Created #{companies_without_subscriptions.count} trial(s)"
    else
      puts "All companies have subscriptions"
    end
  end
end
