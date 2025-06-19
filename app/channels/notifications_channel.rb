class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "User #{current_user.id} subscribed to notifications"
    stream_for current_user
  end

  def unsubscribed
    Rails.logger.info "User #{current_user.id} unsubscribed from notifications"
    stop_all_streams
  end

  def receive(data)
    Rails.logger.info "Received data in NotificationsChannel: #{data.inspect}"
  end
end
