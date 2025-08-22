class SessionsController < ApplicationController
  def google_auth
    user_info = request.env["omniauth.auth"]

    user = User.find_or_create_by(email: user_info["info"]["email"]) do |user|
      user.name = user_info["info"]["name"]
      user.image = user_info["info"]["image"]
      user.provider = user_info["provider"]
      user.uid = user_info["uid"]
      user.password = SecureRandom.hex(15) if user.encrypted_password.blank?
    end

    if user.persisted?
      sign_in_and_redirect user, notice: "Successfully signed in with Google!"
    else
      redirect_to root_path, alert: "Failed to sign in with Google."
    end
  end
end
