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
      "flex items-center p-2 text-white bg-blue-600 rounded-lg dark:bg-blue-500 group transition-colors duration-200"
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

  private

  def active_path?(path)
    current_path == path || current_path.start_with?("#{path}/")
  end
end
