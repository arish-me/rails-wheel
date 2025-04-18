class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("NO_REPLY_EMAIL") { "noreply@wheel.com" }
  layout "mailer"
end
