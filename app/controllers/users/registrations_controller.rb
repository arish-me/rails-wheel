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

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      respond_to do |format|
        format.html do
          flash[:notice] = "Your account has been updated successfully."
          redirect_to after_update_path_for(resource)
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

  protected

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
      :email, :password, :password_confirmation, :current_password,
      profile_attributes: [
        :id, :first_name, :middle_name, :last_name, :gender, :bio,
        :phone_number, :date_of_birth, :location, :website, :social_links,
        :theme_preference, :timezone, :country_code, :postal_code
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

  def update_resource(resource, params)
    # Require current password if user is trying to change password
    return super if params[:password].present?

    # Allows user to update registration information without password
    resource.update_without_password(params.except("current_password", "redirect_to"))
  end
end
