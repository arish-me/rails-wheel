class OnboardingsController < ApplicationController
  layout "wizard"
  before_action :authenticate_user!
  before_action :set_user
  before_action :need_onboard
  before_action :set_candidate, only: %i[specialization candidate_setup online_presence]

  def show
    @company = current_user&.company || Company.new
    # Restore company data from flash if validation failed
    if flash[:company_data].present?
      @company.assign_attributes(flash[:company_data])
      # Ensure avatar is preserved if it was uploaded
      @company.avatar.attach(flash[:company_data]["avatar"]) if flash[:company_data]["avatar"].present?
    end
    @location = current_user.build_location unless current_user.location
    @candidate = current_user.candidate
  end

  def specialization
    if request.get?
      @skills = Skill.order(:name)
    else
      respond_to do |format|
        if @candidate.update(specialization_params)
          flash[:notice] = "Profile was successfully updated."
          handle_redirect(flash[:notice])
          format.html { }
        else
          flash[:alert] = @candidate.errors.full_messages.join(", ")
          format.html { render :specialization, status: :unprocessable_entity }
          format.json { render json: @candidate.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def preferences; end

  def looking_for
    if request.get?
      # Show the looking_for form
    else
      # Handle the form submission
      user_type = params[:user_type]

      if user_type.present? && %w[user company].include?(user_type)
        # Validate email for company users
        if user_type == "company" && @user.email.present?
          validation_result = EmailDomainValidator.validate_company_email(@user.email)
          unless validation_result[:valid]
            flash[:alert] = validation_result[:message]
            render :looking_for, status: :unprocessable_entity
            return
          end
        end

        @user.update(user_type: user_type)

        # The callback will automatically handle candidate creation/destruction

        flash[:notice] = "Great! Let's get you set up."
        redirect_to onboarding_path
      else
        flash[:alert] = "Please select whether you're looking to hire or work."
        render :looking_for, status: :unprocessable_entity
      end
    end
  end

  def profile_setup; end

  def candidate_setup
    if request.get?
      @skills = Skill.order(:name)
    else
      respond_to do |format|
        if @candidate.update(candidate_params)
          flash[:notice] = "Profile was successfully updated."
          handle_redirect(flash[:notice])
          format.html { }
        else
          @skills = Skill.order(:name)
          flash[:alert] = @candidate.errors.full_messages.join(", ")
          format.html { render :candidate_setup, status: :unprocessable_entity }
          format.json { render json: @candidate.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def online_presence
    return if request.get?

    respond_to do |format|
      if @candidate.update(candidate_params)
        flash[:notice] = "Profile was successfully updated."
        handle_redirect(flash[:notice])
        format.html { }
      else
        flash[:alert] = @candidate.errors.full_messages.join(", ")
        format.html { render :online_presence, status: :unprocessable_entity }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  def trial
    # Ensure only company users can access this step
    unless current_user.company_user?
      redirect_to onboarding_path
      return
    end

    # Create trial subscription if it doesn't exist
    return unless current_user.company && !current_user.company.has_subscription?

    current_user.company.create_trial_subscription
  end

  def handle_redirect(notice)
    case params[:candidate][:redirect_to]
    when "online_presence"
      redirect_to online_presence_onboarding_path
    when "onboarding_candidate"
      redirect_to candidate_setup_onboarding_path
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
      redirect_to dashboard_path, notice: notice
    end
  end

  private

  def set_user
    @user = current_user
    @user.in_onboarding_context = true
  end

  def set_candidate
    @user = current_user
    @candidate = @user.candidate
    @candidate_role_groups = CandidateRoleGroup.includes(:candidate_roles).all
  end

  def need_onboard
    redirect_to dashboard_path unless current_user.needs_onboarding?
    redirect_to dashboard_path if current_user.platform_admin?

    # If user doesn't have user_type set and we're not on the looking_for page, redirect
    redirect_to looking_for_onboarding_path if current_user.user_type.blank? && action_name != "looking_for"

    # For company users, redirect to trial step if they don't have a subscription
    if current_user.company_user? && current_user.company && !current_user.company.has_subscription? && action_name != "trial"
      redirect_to trial_onboarding_path
    end
  end

  def load_invitation
    @invitation = Current.family.invitations.accepted.find_by(email: Current.user.email)
  end

  def candidate_params
    params.expect(candidate: [ :redirect_to, :headline, :experience, :hourly_rate,
                              :search_status, :bio, :bio_required,
                              { skill_ids: [],
                                candidate_role_ids: [],
                                role_type_attributes: RoleType::TYPES,
                                role_level_attributes: RoleLevel::TYPES,
                                social_link_attributes: %i[id github website linked_in twitter _destroy] } ])
  end
end
