class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Metrics
    @total_users = User.count
    @total_categories = Category.count

    # Grouped Data
    @users_by_day = User.group_by_day(:created_at).count
    @categories_by_day = Category.group_by_day(:created_at).count

    # Role Distribution
    # @roles_distribution = Role.joins(:user_roles).group(:name).count
  end
end
