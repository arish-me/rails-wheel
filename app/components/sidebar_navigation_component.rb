# frozen_string_literal: true

class SidebarNavigationComponent < ViewComponent::Base
  attr_reader :current_user, :current_path

  def initialize(current_user:, current_path:)
    @current_user = current_user
    @current_path = current_path
  end

  def menu_items
    items = [
      {
        name: "Dashboard",
        path: dashboard_path,
        icon: "layout-dashboard",
        condition: true # Always shown
      },
      {
        name: "User Management",
        path: admin_users_path,
        icon: "users",
        condition: helpers.can?(:index, User)
      },
      {
        name: "Categories",
        path: categories_path,
        icon: "folder",
        condition: helpers.can?(:index, Category)
      }
    ]

    items.select { |item| item[:condition] }
  end

  def active_link_class(path)
    if active_path?(path)
      "flex items-center p-2 text-white bg-gray-900 text-white hover:bg-gray-700 rounded-lg dark:bg-blue-500 group transition-colors duration-200"
    else
      "flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group transition-colors duration-200"
    end
  end

  def active_icon_class
    if active_path?(path)
      "w-5 h-5 text-white transition duration-75 group-hover:text-white"
    else
      "w-5 h-5 text-gray-500 transition duration-75 dark:text-gray-400 group-hover:text-gray-900 dark:group-hover:text-white"
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
