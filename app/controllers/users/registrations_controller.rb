class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.current_sign_in_ip_address = request.remote_ip

    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :email, :password, :password_confirmation,
      profile_attributes: [:first_name, :last_name, :gender, :location]
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
end 