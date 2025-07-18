class OnboardingsController < ApplicationController
  layout "wizard"
  before_action :authenticate_user!
  before_action :set_user
  before_action :need_onboard
  before_action :set_candidate, only: [ :specialization, :candidate_setup, :online_presence ]

  def show
    @company = current_user&.company || Company.new
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

  def preferences
  end

  def profiles_setup
    @company = Company.new
  end

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
    if request.get?
    else
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
  end

  def trial
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
    # when "trial"
    #   redirect_to trial_onboarding_path
    else
      redirect_to dashboard_path, notice: notice
    end
  end

  private
    def set_user
      @user = current_user
    end

    def set_candidate
      @user = current_user
      @candidate = @user.candidate
      @candidate_role_groups = CandidateRoleGroup.includes(:candidate_roles).all
    end

    def need_onboard
      redirect_to dashboard_path unless current_user.needs_onboarding?
      redirect_to dashboard_path if current_user.platform_admin?
    end

    def load_invitation
      @invitation = Current.family.invitations.accepted.find_by(email: Current.user.email)
    end

    def candidate_params
      params.require(:candidate).permit(:redirect_to, :headline, :experience, :hourly_rate,
        :search_status, :bio, :bio_required,
        skill_ids: [],
        candidate_role_ids: [],
        role_type_attributes: RoleType::TYPES,
        role_level_attributes: RoleLevel::TYPES,
        social_link_attributes: [ :id, :github, :website, :linked_in, :twitter, :_destroy ]
      )
    end
end
