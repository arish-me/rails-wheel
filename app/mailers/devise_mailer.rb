class DeviseMailer < Devise::Mailer
  default from: ENV.fetch("NO_REPLY_EMAIL") { "noreply@wheel.com" }
  layout "mailer"
end
