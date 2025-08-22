# To deliver this notification:
#
# UserNotifier.with(record: @post, message: "New post").deliver(User.all)

class UserNotifier < ApplicationNotifier
  # Add your delivery methods

  # Comment out turbo_stream delivery for now to avoid conflicts
  # deliver_by :turbo_stream, class: "DeliveryMethods::TurboStream"

  # deliver_by :database
  deliver_by :action_cable do |config|
    config.channel = 'Noticed::NotificationChannel'
    config.stream = -> { recipient }

    config.message = lambda {
      {
        message: params[:message],
        created_at: Time.current
      }
    }
  end

  # deliver_by :action_cable do |config|
  #   config.channel = "Noticed::NotificationChannel"
  #   config.stream = ->{ recipient }
  #   config.message = ->{ params.merge( user_id: recipient.id) }
  # end

  # Add required params
  required_param :message

  notification_methods do
    def message
      'Welcome back to Wheel'
    end
  end

  # Class method to send welcome back notification
  def self.welcome_back(user)
    with(
      record: user,
      message: "Welcome back, #{user.email}! 👋"
    ).deliver_later(user)
  end

  # Add your delivery methods
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end
end
