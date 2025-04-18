module ProfilesHelper
  def display_user_name(user)
    if user.profile.present?
      [ user.profile.first_name, user.profile.middle_name, user.profile.last_name ].compact.join(" ")
    else
      "Profile not set"
    end
  end
end
