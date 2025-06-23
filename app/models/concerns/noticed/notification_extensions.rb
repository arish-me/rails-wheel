# app/models/concerns/noticed/notification_extensions.rb

module Noticed::NotificationExtensions
  extend ActiveSupport::Concern

  def broadcast_update_to_bell
    broadcast_update_to(
      recipient, # we add this because stream to user
      "notifications_#{recipient.id}",
      target: "notification_bell",
      partial: "layouts/navbar/notifications/bell",
      locals: { user: recipient }
    )
  end

def broadcast_replace_to_index_count
  broadcast_replace_to(
    recipient, # we add this because stream to user
    "notifications_index_#{recipient.id}",
    target: "notifications_index_#{recipient.id}", # Corrected target based on your HTML
    partial: "layouts/navbar/notifications/notifications_count",
    locals: {
      count: recipient.reload.notifications.unread.count,
      unread: recipient.reload.notifications.unread.count,
      user_id: recipient.id # <-- Pass the user_id here
    }
  )
end

  def broadcast_prepend_to_index_list
    broadcast_prepend_to(
      recipient, # we add this because stream to user
      "notificationsList_#{recipient.id}",
      target: "notifications",
      partial: "notifications/notification",
      locals: { notification: self }
    )
  end
end