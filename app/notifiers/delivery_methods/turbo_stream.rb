# app/notifiers/delivery_methods/turbo_stream.rb
class DeliveryMethods::TurboStream < Noticed::DeliveryMethod
  def deliver
    recipient = notification.recipient # This is likely your User object

    Turbo::StreamsChannel.broadcast_to(
      recipient, # This needs to match the object passed to stream_for
      target: "notifications_list",
      action: :prepend,
      partial: "notifications/notification",
      locals: { notification: notification }
    )
  end
end