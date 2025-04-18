# frozen_string_literal: true

class SidebarNavigationComponent < ViewComponent::Base
  attr_reader :current_user

  def initialize(current_user:)
    @current_user = current_user
  end

  def menu_items
    items = [
      {
        name: "Dashboard",
        path: dashboard_path,
        icon: 'layout-dashboard',
        condition: true # Always shown
      },
      {
        name: "User Management",
        path: admin_users_path,
        icon: 'users',
        condition: helpers.can?(:index, User)
      },
      {
        name: "Categories",
        path: categories_path,
        icon: 'folder',
        condition: helpers.can?(:index, Category)
      }
    ]

    items.select { |item| item[:condition] }
  end
end
