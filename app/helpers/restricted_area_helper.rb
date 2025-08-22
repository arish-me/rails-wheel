module RestrictedAreaHelper
  # Helper for login-required restrictions
  def restricted_for_login(content = nil, message: nil, &block)
    render RestrictedAreaComponent.new(
      show_login_button: !user_signed_in?,
      message: message || "Sign in to access this feature",
      blur: !user_signed_in?,
      overlay: !user_signed_in?
    ) do
      content || capture(&block)
    end
  end

  # Helper for trial-required restrictions
  def restricted_for_trial(content = nil, message: nil, &block)
    render RestrictedAreaComponent.new(
      show_trial_button: !user_signed_in?,
      message: message || "Start your free trial to unlock this feature",
      blur: true,
      overlay: !user_signed_in?
    ) do
      content || capture(&block)
    end
  end

  # Helper for upgrade-required restrictions
  def restricted_for_upgrade(content = nil, message: nil, condition: nil, &block)
    should_restrict = condition || current_user&.company&.trial_expired?

    render RestrictedAreaComponent.new(
      show_upgrade_button: should_restrict,
      message: message || "Upgrade your plan to continue",
      blur: true,
      overlay: should_restrict
    ) do
      content || capture(&block)
    end
  end

  # Helper for subscription-required restrictions
  def restricted_for_subscription(content = nil, message: nil, &block)
    render RestrictedAreaComponent.new(
      show_upgrade_button: current_user&.company&.subscription_expired?,
      message: message || "Your subscription has expired. Renew to continue.",
      blur: true,
      overlay: current_user&.company&.subscription_expired?
    ) do
      content || capture(&block)
    end
  end

  # Helper for admin-required restrictions
  def restricted_for_admin(content = nil, message: nil, &block)
    render RestrictedAreaComponent.new(
      show_login_button: !current_user&.admin?,
      message: message || "Admin access required",
      blur: true,
      overlay: !current_user&.admin?
    ) do
      content || capture(&block)
    end
  end

  # Generic restriction helper
  def restricted_area(condition:, content: nil, message: nil, action_text: nil, action_url: nil, &block)
    render RestrictedAreaComponent.new(
      message: message,
      action_text: action_text,
      action_url: action_url,
      blur: true,
      overlay: condition
    ) do
      content || capture(&block)
    end
  end
end
