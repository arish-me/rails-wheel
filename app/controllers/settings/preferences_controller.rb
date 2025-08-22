module Settings
  class PreferencesController < ApplicationController
    layout "settings"

    def show
      @user = current_user
    end
  end
end
