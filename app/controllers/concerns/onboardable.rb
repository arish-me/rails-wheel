module Onboardable
  extend ActiveSupport::Concern

  included do
    # before_action :need_onboard
    before_action :require_onboarding_and_upgrade
  end

  private
    # First, we require onboarding, then once that's complete, we require an upgrade for non-subscribed users.
    def require_onboarding_and_upgrade
      return unless current_user
      return false if current_user.platform_admin?
      return unless redirectable_path?(request.path)

      if current_user.needs_onboarding?
        # If user doesn't have a user_type set, redirect to looking_for step first
        if current_user.user_type.blank?
          redirect_to looking_for_onboarding_path
        else
          redirect_to onboarding_path
        end
        # elsif Current.family.needs_subscription?
        #   redirect_to trial_onboarding_path
        # elsif Current.family.upgrade_required?
        #   redirect_to upgrade_subscription_path
      end
    end

    def redirectable_path?(path)
      return false if path.starts_with?("/settings")
      return false if path.starts_with?("/subscription")
      return false if path.starts_with?("/onboarding")
      return false if path.starts_with?("/users")
      return false if path.starts_with?("/companies")
      return false if path.starts_with?("/location")



      [
        new_registration_path(User),
        new_session_path(User)
        # new_password_reset_path,
        # new_email_confirmation_path,
      ].exclude?(path)
    end
end
