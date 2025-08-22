module Settings
  class SubscriptionsController < ApplicationController
    layout "settings"
    before_action :authenticate_user!

    def show
      @company = current_user.company
      @subscription = @company.company_subscription
    end
  end
end
