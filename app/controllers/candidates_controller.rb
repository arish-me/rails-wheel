class CandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate, only: %i[ show edit update ]

  def index
    @profile = @candidate&.profile ? @candidate.profile : @candidate.build_profile
  end

  def show
    @profile = @candidate.profile ? @candidate.profile : @candidate.build_profile
  end

  def edit
    @candidate.build_profile unless @candidate.profile
    @candidate.build_user unless @candidate.user
    @candidate.build_work_preference unless @candidate.work_preference
    @candidate.build_role_type unless @candidate.role_type
    @candidate.build_role_level unless @candidate.role_level
    @candidate.build_social_link unless @candidate.social_link
    @candidate.build_location unless @candidate.location
  end

def update
  respond_to do |format|
    if @candidate.update(candidate_params)
      flash[:notice] =  "Profile was successfully updated."
      # format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      format.html { redirect_to @candidate, notice: "Profile was successfully updated." }

    else
      flash[:alert] = @candidate.errors.full_messages.join(", ")
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @candidate.errors, status: :unprocessable_entity }
    end
  end
end

  private

  def set_candidate
    @candidate = current_user.candidate
  end

  def candidate_params
    params.require(:candidate).permit(

      profile_attributes: [ :id, :headline, :candidate_role_id, :experience, :_destroy ],
      user_attributes: [ :id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio, :profile_image, :delete_profile_image, :cover_image ],
      work_preference_attributes: [ :id, :search_status ],
      social_link_attributes: [ :id, :github, :website, :linked_in, :twitter, :_destroy ],
      location_attributes: [ :city, :state, :country_code ],
      role_type_attributes: RoleType::TYPES,
      role_level_attributes: RoleLevel::TYPES
    )
  end
end
