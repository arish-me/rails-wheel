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
      "block px-4 py-2 text-sm bg-gray-100 text-alpha-black-600 dark:bg-gray-600 dark:text-blue-400"
    else
      "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-600 dark:hover:text-white"
    end
  end

  def active_path?(path)
  # Clean and normalize paths
  clean_current = normalize_path(current_path)
  clean_path = normalize_path(path)

  # Case 1: Exact match
  return true if clean_current == clean_path

  # Case 2: Current path is a sub-path
  return true if clean_path.present? &&
                 clean_path != "/" &&
                 clean_current.start_with?("#{clean_path}/")

  # Case 3: Resource identification (e.g., /users and /users/123 should match)
  current_resource = resource_from_path(clean_current)
  path_resource = resource_from_path(clean_path)

  current_resource.present? &&
         path_resource.present? &&
         current_resource == path_resource
end

private

def normalize_path(path)
  # Remove trailing slashes and query params
  path.split("?").first.chomp("/")
end

def resource_from_path(path)
  segments = path.split("/").reject(&:empty?)
  return nil if segments.empty?

  # Extract the resource name from the path (typically the first segment)
  # This works for standard RESTful routes like /users, /users/new, /users/123, etc.
  segments.first
end
end
