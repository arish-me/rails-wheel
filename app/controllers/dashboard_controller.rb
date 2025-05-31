class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    return unless current_user.company.present?
    ActsAsTenant.with_tenant(current_user.company) do
      # Metrics
      @total_users = ActsAsTenant.current_tenant.users.count
      @total_categories = Category.count

      # Grouped Data
      @users_by_day = ActsAsTenant.current_tenant.users.group_by_day(:created_at).count
      @categories_by_day = Category.group_by_day(:created_at).count

      # Role Distribution
      # @roles_distribution = Role.joins(:user_roles).group(:name).count
    end
  end
end
