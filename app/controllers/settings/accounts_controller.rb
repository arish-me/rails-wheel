module Settings
  class AccountsController < ApplicationController
    layout 'settings'
    before_action :authenticate_user!

    def show
      @user = current_user
    end

    def new
      @user = current_user
      @minimum_password_length = Devise.password_length.min
    end

    private

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || settings_profile_accounts_path
    end

    def after_update_path_for(_resource)
      settings_profile_accounts_path
    end
  end
end
