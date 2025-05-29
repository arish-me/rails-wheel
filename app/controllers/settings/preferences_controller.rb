class Settings::PreferencesController < ApplicationController
  layout "settings"

  def show
    @user = current_user
  end
end
