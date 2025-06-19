class NotificationsController < ApplicationController
  def index
    @unread_count = @current_user.notifications.unread.count
    # Fix the N+1 query here by adding .includes(:event)
    @notifications = @current_user.notifications.includes(:event).order(created_at: :desc)
  end

  def show
    @unread_count = @current_user.notifications.unread.count
    @notifications = @current_user.notifications
  end

  def users_list
    users = User.select(:id, :email)
    render json: users
  end

  def mark_as_read
    Noticed::Notification.find(params[:id])&.mark_as_read
  end

  # POST /notifications/send_to_user
  # Params: user_id, message (optional)
  def send_to_user
    user = User.find_by(id: params[:user_id])
    if user
      # Assuming Notification model has a create_for_user method or similar
      UserNotifier.welcome_back(user)
      # Notification.create(user: user, message: params[:message] || 'You have a new notification!')
      render json: { success: true, message: "Notification sent." }
    else
      render json: { success: false, message: "User not found." }, status: :not_found
    end
  end

  def app_sender
    # Renders app/views/notifications/send.html.erb
  end
end
