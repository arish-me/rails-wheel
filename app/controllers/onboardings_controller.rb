class OnboardingsController < ApplicationController
  layout "wizard"

  before_action :set_user
  before_action :need_onboard
  # before_action :load_invitation

  def show
  end

  def preferences
  end

  def trial
  end

  private
    def set_user
      @user = current_user
    end

    def need_onboard
      redirect_to dashboard_path unless current_user.needs_onboarding?
    end

    def load_invitation
      @invitation = Current.family.invitations.accepted.find_by(email: Current.user.email)
    end
end
