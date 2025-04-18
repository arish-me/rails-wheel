# frozen_string_literal: true

class TopNavigationComponent < ViewComponent::Base
  attr_reader :current_user, :current_path

  def initialize(current_user:, current_path: nil)
    @current_user = current_user
    @current_path = current_path || helpers.request.path
  end

  def display_user_name
    current_user.profile&.display_name || current_user.email
  end

  def dropdown_menu_items
    [
      {
        name: "Dashboard",
        path: helpers.dashboard_path,
        icon: "layout-dashboard"
      },
      {
        name: "Settings",
        path: helpers.edit_settings_profile_path,
        icon: "settings"
      },
      {
        name: "Sign Out",
        path: helpers.destroy_user_session_path,
        icon: "log-out",
        data: { turbo_method: :delete }
      }
    ]
  end

  def active_dropdown_item_class(path)
    if active_path?(path)
      "block px-4 py-2 text-sm bg-gray-100 text-blue-600 dark:bg-gray-600 dark:text-blue-400"
    else
      "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-600 dark:hover:text-white"
    end
  end

  private

  def active_path?(path)
    current_path == path || current_path.start_with?("#{path}/")
  end
end
