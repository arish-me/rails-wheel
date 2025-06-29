class CandidatesController < ApplicationController
  before_action :set_candidate, only: %i[ show edit update ]
  def index
    @profile = @candidate.profile ? @candidate.profile : @candidate.build_profile
  end

  def show
    @profile = @candidate.profile ? @candidate.profile : @candidate.build_profile
  end

  def update
  end

  def edit
    @candidate.build_profile unless @candidate.profile
    @candidate.build_user unless @candidate.user
  end

def update
  if @candidate.update(candidate_params)
    redirect_to @candidate, notice: "Profile updated!"
  else
    render :edit
  end
end

  private

  def set_candidate
    @candidate = current_user.candidate
  end

  def candidate_params
    params.require(:candidate).permit(
      profile_attributes: [ :id, :headline, :_destroy ],
      user_attributes: [ :id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio ]
    )
  end
end
