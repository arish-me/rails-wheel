class OnboardingsController < ApplicationController
  layout "wizard"
  before_action :authenticate_user!
  before_action :set_user
  before_action :need_onboard
  before_action :set_candidate, only: [ :specialization ]
  # before_action :load_invitation

  def show
    @company = current_user&.company || Company.new
    @location = current_user.build_location unless current_user.location
    @candidate = current_user.candidate
  end

  def specialization
    unless request.get?
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

  def trial
  end

  def handle_redirect(notice)
    case params[:candidate][:redirect_to]
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
      # path = current_user.user? ? : settings_profile_path
      redirect_to settings_profile_path, notice: notice
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

    def specialization_params
      params.require(:candidate).permit(:redirect_to,
        candidate_role_ids: [],
      )
    end
end
