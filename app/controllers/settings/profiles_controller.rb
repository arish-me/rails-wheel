module Settings
  class ProfilesController < ApplicationController
    layout 'settings'
    before_action :authenticate_user!

    def show
      @user = current_user
    end
  end
end
