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

      # Set name information from Google OAuth
      set_user_name_from_oauth(user, user_info)
    end

    if user.persisted?
      # Update name if user exists but doesn't have it set
      if user.first_name.blank? || user.last_name.blank?
        set_user_name_from_oauth(user, user_info)
        user.save
      end

      # Create or update the profile for the user
      user.attach_avatar(user_info["info"]["image"])

      # Check if user needs to complete their profile or select user_type
      if user.needs_profile_completion?
        sign_in user, event: :authentication
        redirect_to settings_profile_path, notice: "Welcome! Please complete your profile information."
      elsif user.user_type.blank?
        # If user doesn't have user_type set, redirect to looking_for step
        sign_in user, event: :authentication
        redirect_to looking_for_onboarding_path, notice: "Welcome! Let's get you started."
      else
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      end
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
      user.attach_avatar(user_info["info"]["image"])
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

  private

  def set_user_name_from_oauth(user, user_info)
    info = user_info["info"]

    # Try to get first name from multiple possible sources
    first_name = info["first_name"] ||
                 info["given_name"] ||
                 extract_first_name_from_full_name(info["name"]) ||
                 "User"

    # Try to get last name from multiple possible sources
    last_name = info["last_name"] ||
                info["family_name"] ||
                extract_last_name_from_full_name(info["name"]) ||
                generate_fallback_last_name(info["email"])

    user.first_name = first_name
    user.last_name = last_name
  end

  def extract_first_name_from_full_name(full_name)
    return nil unless full_name.present?

    # Split by space and take the first part
    name_parts = full_name.strip.split(/\s+/)
    name_parts.first if name_parts.any?
  end

  def extract_last_name_from_full_name(full_name)
    return nil unless full_name.present?

    # Split by space and take everything after the first part
    name_parts = full_name.strip.split(/\s+/)
    return nil if name_parts.length <= 1

    name_parts[1..-1].join(" ")
  end

  def generate_fallback_last_name(email)
    return "User" unless email.present?

    # Extract domain name from email as a fallback
    domain = email.split("@").last&.split(".")&.first
    domain&.capitalize || "User"
  end
end
