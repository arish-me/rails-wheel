module Settings
  class SubscriptionsController < ApplicationController
    layout "settings"
    before_action :authenticate_user!

    def show
      @user = current_user
      @subscription = current_user.company.company_subscriptions.first
    end
  end
end
