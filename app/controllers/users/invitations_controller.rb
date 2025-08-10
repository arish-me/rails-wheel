class Users::InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!
  # before_action :authenticate_inviter!
  before_action :set_inviter, only: [ :create ]

  # # GET /resource/invitation/new
  # def new
  #   self.resource = resource_class.new
  #   render :new
  # end

  # POST /resource/invitation
  def create
    # Check for existing user before sending invitation
    existing_user = User.find_by(email: invite_params[:email])

    if existing_user
      error_message = get_existing_user_error(existing_user)
      self.resource = resource_class.new(invite_params)
      resource.errors.add(:email, error_message)
      render :new, status: :unprocessable_entity
      return
    end

    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, email: self.resource.email
      end
      if self.method(:after_invite_path_for).arity == 1
        respond_with resource, location: after_invite_path_for(self.resource)
      else
        respond_with resource, location: after_invite_path_for(self.resource, self.resource)
      end
    else
      respond_with_navigational(resource) { render :new, status: :unprocessable_entity }
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    set_minimum_password_length
    resource.invitation_token = params[:invitation_token]
    render :edit
  end

  # PUT /resource/invitation
  def update
    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      resource.skip_confirmation!
      set_flash_message :notice, :updated_not_active
      sign_in(resource_name, resource)
      respond_with resource, location: after_accept_path_for(resource)
    else
      resource.invitation_token = raw_invitation_token
      respond_with_navigational(resource) { render :edit, status: :unprocessable_entity }
    end
  end

  # GET /resource/invitation/remove?invitation_token=abcdef
  def destroy
    resource = resource_class.find_by_invitation_token(params[:invitation_token], true)
    resource.destroy
    set_flash_message :notice, :invitation_removed
    redirect_to after_sign_out_path_for(resource_name)
  end

  protected

  def invite_resource(&block)
    # Set company and user type for the invited user
    resource = resource_class.invite!(invite_params, current_inviter, &block)

    return resource unless resource.errors.blank?

    if resource.persisted?
      # Set the company to the inviter's company using update_columns to avoid validations
      # Only set company_id if the inviter has a company
      update_attrs = {
        user_type: "company",
        onboarded_at: Time.current, # Skip onboarding for invited users
        active: false
      }

      if current_inviter.company_id.present?
        update_attrs[:company_id] = current_inviter.company_id
      end

      resource.update_columns(update_attrs)
      debugger
      # Assign default role for the company if company exists
      if current_inviter.company_id.present?
        resource.assign_default_role
      end
    end

    resource
  end

  def accept_resource
    resource_class.accept_invitation!(update_resource_params)
  end

  def current_inviter
    @current_inviter ||= authenticate_inviter!
  end

  def has_invitations_left?
    unless current_inviter.respond_to?(:has_invitations_left?) && current_inviter.has_invitations_left?
      self.resource = resource_class.new
      resource.errors.add(:base, :no_invitations_remaining)
      render :new, status: :unprocessable_entity
      return false
    end
    true
  end

  def invite_params
    devise_parameter_sanitizer.sanitize(:invite)
  end

  def update_resource_params
    devise_parameter_sanitizer.sanitize(:accept_invitation)
  end

  def set_inviter
    @inviter = current_user
  end

  def authenticate_inviter!
    unless current_user
      redirect_to root_path, alert: "You don't have permission to invite users."
    end
    current_user
  end

  def after_invite_path_for(resource)
    if current_user.platform_admin?
      platform_users_path
    else
      admin_users_path
    end
  end

  def after_accept_path_for(resource)
    dashboard_path
  end

  private

  def get_existing_user_error(existing_user)
    if existing_user.platform_admin?
      "This email belongs to a platform administrator and cannot be invited."
    elsif existing_user.invitation_sent_at.present? && existing_user.invitation_accepted_at.blank?
      "This user has already been invited and is waiting to accept the invitation."
    elsif existing_user.invitation_accepted_at.present?
      "This user has already accepted an invitation and has an active account."
    elsif existing_user.company_id.present?
      if current_inviter.company_id == existing_user.company_id
        "This user is already a member of your company."
      else
        "This user is already a member of another company (#{existing_user.company.name})."
      end
    else
      "This email is already registered in our system."
    end
  end
end
