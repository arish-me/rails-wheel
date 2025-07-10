class OnboardingsController < ApplicationController
  layout "wizard"
  before_action :authenticate_user!
  before_action :set_user
  before_action :need_onboard
  # before_action :load_invitation

  def show
    @company = current_user&.company || Company.new
    @location = current_user.build_location unless current_user.location
    @candidate = current_user.candidate
  end

  def specialization
    @user = current_user
    @candidate = @user.candidate
    @candidate_role_groups = CandidateRoleGroup.includes(:candidate_roles).all
  end

  def preferences
  end

  def profiles_setup
    @company = Company.new
  end

  def trial
  end

  private
    def set_user
      @user = current_user
    end

    def need_onboard
      redirect_to dashboard_path unless current_user.needs_onboarding?
      redirect_to dashboard_path if current_user.platform_admin?
    end

    def load_invitation
      @invitation = Current.family.invitations.accepted.find_by(email: Current.user.email)
    end
end
