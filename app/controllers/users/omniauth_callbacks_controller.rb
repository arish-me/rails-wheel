# app/controllers/users/omniauth_callbacks_controller.rb
require "open-uri"

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user_info = request.env["omniauth.auth"]

    # Find or create the user
    user = User.find_or_create_by(email: user_info["info"]["email"]) do |user|
      user.provider = user_info["provider"]
      user.uid = user_info["uid"]
      user.password = SecureRandom.hex(15) if user.encrypted_password.blank?
      user.skip_confirmation!
    end

    if user.persisted?
      # Create or update the profile for the user
      user.profile ||= user.build_profile(google_user(user_info))
      user.profile.save
      user.profile.attach_avatar(user_info["info"]["image"])
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      redirect_to new_user_registration_url, alert: "There was an issue signing in with Google."
    end
  end

  def google_user(user_info)
    {
      first_name: user_info["info"]["first_name"],
      last_name: user_info["info"]["name"].split.last # Extract last name from full name
    }
  end

  def github
    user_info = request.env["omniauth.auth"]

    # Find or create the user
    user = User.find_or_create_by(email: user_info["info"]["email"]) do |user|
      user.provider = user_info["provider"]
      user.uid = user_info["uid"]
      user.password = SecureRandom.hex(15) if user.encrypted_password.blank?
      user.skip_confirmation!
    end

    if user.persisted?
      # Create or update the profile for the user
      user.profile ||= user.build_profile(github_user(user_info))
      user.profile.save
      user.profile.attach_avatar(user_info["info"]["image"])
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      redirect_to new_user_registration_url, alert: "There was an issue signing in with GitHub."
    end
  end

  def github_user(user_info)
    {
      first_name: user_info["info"]["name"].split.first, # GitHub may not provide first name explicitly
      last_name: user_info["info"]["name"].split.last,  # Extract last name
      bio: user_info["info"]["bio"]                   # GitHub bio
    }
  end


  def failure
    redirect_to root_path, alert: "Google authentication failed."
  end
end
