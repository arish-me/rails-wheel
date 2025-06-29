class CandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate, only: %i[ show edit update ]

  def index
    @profile = @candidate&.profile ? @candidate.profile : @candidate.build_profile
  end

  def show
    @profile = @candidate.profile ? @candidate.profile : @candidate.build_profile
  end

  def update
  end

  def edit
    @candidate.build_profile unless @candidate.profile
    @candidate.build_user unless @candidate.user
    @candidate.build_work_preference unless @candidate.work_preference
    @candidate.build_role_type unless @candidate.role_type
    @candidate.build_role_level unless @candidate.role_level
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
      user_attributes: [ :id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio ],
      work_preference_attributes: [ :id, :search_status, :role_type, :role_level, :_destroy ],
      role_type_attributes: RoleType::TYPES,
      role_level_attributes: RoleLevel::TYPES
    )
  end
end
