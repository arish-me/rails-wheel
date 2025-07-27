class Settings::CompaniesController < ApplicationController
  layout "settings"

  def show
    @user = current_user
    @company = current_user.company
  end
end
