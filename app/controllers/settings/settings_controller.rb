# app/controllers/settings/settings_controller.rb
module Settings
  class SettingsController < ApplicationController
    before_action :authenticate_user!

    def edit_account
      render "devise/registrations/edit", locals: { resource: current_user, resource_name: :user }
    end
  end
end
