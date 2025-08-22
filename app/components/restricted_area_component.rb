class RestrictedAreaComponent < ViewComponent::Base
  def initialize(
    message: nil,
    action_text: nil,
    action_url: nil,
    action_method: :get,
    blur: true,
    overlay: true,
    show_login_button: false,
    show_upgrade_button: false,
    show_trial_button: false,
    custom_class: nil
  )
    @message = message
    @action_text = action_text
    @action_url = action_url
    @action_method = action_method
    @blur = blur
    @overlay = overlay
    @show_login_button = show_login_button
    @show_upgrade_button = show_upgrade_button
    @show_trial_button = show_trial_button
    @custom_class = custom_class
  end

  private

  attr_reader :message, :action_text, :action_url, :action_method, :blur, :overlay,
              :show_login_button, :show_upgrade_button, :show_trial_button, :custom_class

  def overlay_classes
    base_classes = "absolute inset-0 bg-white/80 backdrop-blur-sm rounded-2xl flex items-center justify-center z-10"
    base_classes += " #{custom_class}" if custom_class.present?
    base_classes
  end

  def content_classes
    blur ? "filter blur-sm pointer-events-none" : ""
  end

  def default_message
    if show_login_button
      "Sign in to access this feature"
    elsif show_upgrade_button
      "Upgrade your plan to continue"
    elsif show_trial_button
      "Start your free trial to unlock this feature"
    else
      "Access restricted"
    end
  end

  def default_action_text
    if show_login_button
      "Sign In"
    elsif show_upgrade_button
      "Upgrade Now"
    elsif show_trial_button
      "Start Free Trial"
    else
      "Learn More"
    end
  end

  def default_action_url
    if show_login_button
      new_user_session_path
    elsif show_upgrade_button
      pricing_path
    elsif show_trial_button
      new_user_registration_path
    else
      "#"
    end
  end

  def button_classes
    "inline-flex items-center px-4 py-2 rounded-lg text-sm font-semibold bg-gradient-to-r from-blue-600 to-indigo-600 text-white hover:from-blue-700 hover:to-indigo-700 transform transition-all duration-200 hover:scale-105 shadow-lg"
  end
end
