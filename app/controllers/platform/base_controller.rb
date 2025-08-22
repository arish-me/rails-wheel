# app/controllers/platform/base_controller.rb
module Platform
  class BaseController < ApplicationController
    # Ensure a user is logged in
    before_action :authenticate_user!
    # Authorize that the logged-in user is a platform_admin
    before_action :authorize_platform_admin!

    # --- CRITICAL FIX FOR REDIRECT LOOP ---
    # Skip filters that set a tenant or enforce onboarding for the admin panel.
    # Replace `set_tenent` and `require_onboarding_and_upgrade` with the actual names
    # of your methods in ApplicationController.
    skip_before_action :set_tenent, only: %i[index show new create edit update destroy]
    skip_before_action :require_onboarding_and_upgrade, only: %i[index show new create edit update destroy]
    # You might want to use `except: []` or `prepend_before_action` depending on your filter chain.
    # `skip_before_action :set_tenent` without `only` would skip for all actions if you desire.

    private

    def authorize_platform_admin!
      return if current_user&.platform_admin?

      flash[:alert] = "You are not authorized to access this section."
      redirect_to main_app.root_path # Redirect to a safe place for unauthorized users
    end
  end
end
