# # app/notifiers/delivery_methods/turbo_stream.rb
# class DeliveryMethods::TurboStream < ApplicationDeliveryMethod
#   def deliver
#     recipient = notification.recipient # This is likely your User object

#     Turbo::StreamsChannel.broadcast_to(
#       notification.recipient, # This needs to match the object passed to stream_for
#       target: "notificationsList",
#       action: :prepend,
#       partial: "notifications/notification",
#       locals: { notification: notification }
#     )
#   end
# end

# app/notifiers/delivery_methods/turbo_stream.rb

class DeliveryMethods::TurboStream < ApplicationDeliveryMethod
  def deliver
    return unless recipient.is_a?(User)

    notification.broadcast_update_to_bell
    notification.broadcast_replace_to_index_count
    notification.broadcast_prepend_to_index_list
  end
end
