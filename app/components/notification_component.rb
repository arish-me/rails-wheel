class NotificationComponent < ViewComponent::Base
  def initialize(current_user:, placement: "bottom-end", offset: 0)
    @current_user = current_user
    @placement = placement
    @offset = offset
    @unread_count = @current_user.notifications.unread.count
    @notifications = @current_user.notifications
  end
end
