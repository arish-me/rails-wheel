class CandidatesController < ApplicationController
  before_action :set_candidate, only: %i[ show edit update ]

  def index
  end
  def show
  end
  def edit
    # @location = current_user.build_location unless current_user.location
  end

  def update
    respond_to do |format|
      if @candidate.update(candidate_params)
        flash[:notice] = "Profile was successfully updated."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to candidate_path(@candidate), notice: "Profile was successfully updated." }
      else
        flash.now[:alert] = @candidate.errors.full_messages.join(", ")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
   end

  def set_candidate
    @candidate = current_user.candidate
    @user = @candidate.user
    @candidate_role_groups = CandidateRoleGroup.includes(:candidate_roles).all
    @skills = Skill.order(:name)
  end

  private
  def candidate_params
    params.require(:candidate).permit(
      :bio, :redirect_to,
      user_attributes: [ :id, :first_name, :last_name, :phone_number, :gender, :date_of_birth, :email_required, :delete_profile_image, :profile_image,
      location_attributes: [ :id, :location_search, :city, :state, :country, :_destroy ]
      ],
      skill_ids: [],
      candidate_role_ids: [],
      role_type_attributes: RoleType::TYPES,
      role_level_attributes: RoleLevel::TYPES,
      social_link_attributes: [ :id, :github, :website, :linked_in, :twitter, :_destroy ]
    )
  end
end
