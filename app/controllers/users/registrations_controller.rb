class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.current_sign_in_ip_address = request.remote_ip

    super
  end

  # PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    onboarding = params[:user][:redirect_to] == "home" || resource.needs_onboarding?
    resource_updated = if onboarding
                        update_resource_without_password(resource, account_update_params)
    elsif params[:user][:redirect_to] == "settings_accounts_path"
      update_resource(resource, account_update_params)
    else
                        update_resource_without_password(resource, account_update_params)
    end
    resource.profile_image.purge if should_purge_profile_image?
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      respond_to do |format|
        format.html do
          flash[:notice] = "Your account has been updated successfully."
          handle_redirect(flash[:notice], resource)
        end
        format.json { render json: { message: "Account updated successfully" }, status: :ok }
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_to do |format|
        format.html do
          flash[:alert] = resource.errors.full_messages.join(", ")
          redirect_to request.referer || after_update_path_for(resource)
        end
        format.json { render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

    def handle_redirect(notice, resource)
      case params[:user][:redirect_to]
      when "onboarding_preferences"
        redirect_to preferences_onboarding_path
      when "home"
        redirect_to root_path
      when "preferences"
        redirect_to settings_preferences_path, notice: notice
      when "goals"
        redirect_to goals_onboarding_path
      when "trial"
        redirect_to trial_onboarding_path
      else
        redirect_to settings_profile_path, notice: notice
      end
    end

  protected

  def should_purge_profile_image?
    account_update_params[:delete_profile_image] == "1" &&
      account_update_params[:profile_image].blank?
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :email, :password, :password_confirmation,
      profile_attributes: [ :first_name, :last_name, :gender, :location ]
    ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :email, :password, :password_confirmation, :current_password, :set_onboarding_goals_at, :onboarded_at, :redirect_to,
      :first_name, :last_name, :country_code, :theme, :set_onboarding_preferences_at, :delete_profile_image, :profile_image,
      :date_format, :locale, :gender, :phone_number, :date_of_birth, :bio, :timezone,
      profile_attributes: [
        :id, :last_name, :gender, :bio,
        :phone_number, :date_of_birth, :location, :website, :social_links,
        :timezone, :postal_code
      ]
    ])
  end

  def after_update_path_for(resource)
    if params[:user][:redirect_to].present?
      path = params[:user][:redirect_to]
      path.start_with?("/") ? path : "/#{path}"
    else
      super
    end
  end

  def update_resource_without_password(resource, params)
    resource.update_without_password(params.except(:redirect_to, :delete_profile_image, :redirect_to))
  end

  def update_resource(resource, params)
    # Require current password if user is trying to change password
    return super if params[:password].present?
    resource.update_with_password(params.except(:delete_profile_image, :redirect_to))
    # Allows user to update registration information without password
    # resource.update_without_password(params.except("current_password", "redirect_to"))
  end
end
