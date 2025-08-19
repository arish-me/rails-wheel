# Seed Subscription Plans
puts "Creating subscription plans..."

# Bronze Tier
bronze_plan = SubscriptionPlan.find_or_create_by(name: 'Bronze Tier') do |plan|
  plan.description = 'Perfect for small businesses and startups'
  plan.price = 999
  plan.tier = 'bronze'
  plan.trial_days = 30
  plan.active = true
  plan.features = {
    'job_posting_limit' => 5,
    'candidate_search_limit' => 50,
    'analytics_dashboard' => false,
    'priority_support' => false,
    'api_access' => false,
    'custom_branding' => false
  }
end

# Silver Tier
silver_plan = SubscriptionPlan.find_or_create_by(name: 'Silver Tier') do |plan|
  plan.description = 'Ideal for growing companies'
  plan.price = 2499
  plan.tier = 'silver'
  plan.trial_days = 30
  plan.active = true
  plan.features = {
    'job_posting_limit' => 15,
    'candidate_search_limit' => 200,
    'analytics_dashboard' => true,
    'priority_support' => false,
    'api_access' => false,
    'custom_branding' => false
  }
end

# Gold Tier
gold_plan = SubscriptionPlan.find_or_create_by(name: 'Gold Tier') do |plan|
  plan.description = 'Complete solution for enterprise companies'
  plan.price = 4999
  plan.tier = 'gold'
  plan.trial_days = 30
  plan.active = true
  plan.features = {
    'job_posting_limit' => 0, # unlimited
    'candidate_search_limit' => 0, # unlimited
    'analytics_dashboard' => true,
    'priority_support' => true,
    'api_access' => true,
    'custom_branding' => true
  }
end

puts "✅ Subscription plans created:"
puts "- #{bronze_plan.name}: #{bronze_plan.display_price}/month"
puts "- #{silver_plan.name}: #{silver_plan.display_price}/month"
puts "- #{gold_plan.name}: #{gold_plan.display_price}/month"
