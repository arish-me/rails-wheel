module Settings
  class ProfilesSetupController < ApplicationController
    layout "settings"
    before_action :authenticate_user!

    def show
      @user = current_user
    end
  end
end
