class Settings::PreferencesController < ApplicationController
  layout "settings"

  def show
    @profile = current_user.profile
  end
end
