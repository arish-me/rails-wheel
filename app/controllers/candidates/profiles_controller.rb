class Candidates::ProfilesController < ApplicationController
  before_action :set_candidate
  before_action :set_profile, only: [ :show, :edit, :update, :destroy ]

  def index
    # @profiles = @candidate.profiles if @candidate.respond_to?(:profiles)
    @profile = @candidate.profile ? @candidate.profile : @candidate.build_profile
  end

  def show
  end

  def new
    @profile = @candidate.build_profile
  end

  def create
    @profile = @candidate.build_profile(profile_params)

    if @profile.save
      redirect_to candidate_profile_path(@candidate, @profile), notice: "Profile was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Ensure associated models are built
    @candidate.build_profile unless @candidate.profile
    @candidate.build_user unless @candidate.user
    @candidate.build_social_link unless @candidate.social_link
    @candidate.build_location unless @candidate.location
  end

  def update
    respond_to do |format|
      if @candidate.update(candidate_params)
        flash[:notice] =  "Professional information was successfully updated."
        format.html { redirect_to edit_candidate_profile_path(@candidate, @profile), notice: "Professional information was successfully updated." }
      else
        # Build associated models if they don't exist for proper form rendering
        @candidate.build_profile unless @candidate.profile
        @candidate.build_user unless @candidate.user
        @candidate.build_social_link unless @candidate.social_link
        @candidate.build_location unless @candidate.location
        
        flash[:alert] = @candidate.errors.full_messages.join(", ")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @profile.destroy
    redirect_to candidate_profiles_path(@candidate), notice: "Profile was successfully deleted."
  end

  private

  def set_candidate
    @candidate = Candidate.find(params[:candidate_id])
  end

  def set_profile
    @profile = @candidate.profile
  end

  def profile_params
    params.require(:candidate_profile).permit(:candidate_role_id, :headline)
  end

  def candidate_params
    params.require(:candidate).permit(
      profile_attributes: [:id, :headline, :candidate_role_id],
      user_attributes: [:id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio, :profile_image, :delete_profile_image, :cover_image],
      social_link_attributes: [:id, :github, :website, :linked_in, :twitter]
    )
  end
end
