class Candidates::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate
  before_action :set_profile, only: [ :show, :update ]

  def show
    @profile.build_user unless @profile.user
    @profile.user.build_location unless @profile.user.location
  end

  def create
    @profile = @candidate.build_profile(profile_params)

    if @profile.save
      redirect_to candidate_profile_path(@candidate), notice: "Profile was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @profile.update(profile_params)
        flash[:notice] =  "Professional information was successfully updated."
        format.html { redirect_to candidate_profile_path(@candidate), notice: "Professional information was successfully updated." }
      else
        flash[:alert] = @profile.errors.full_messages.join(", ")
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_candidate
    @candidate = current_user.candidate
  end

  def set_profile
    @profile = @candidate.profile || @candidate.build_profile
  end

  def profile_params
    params.require(:candidate_profile).permit(:candidate_role_id, :headline,
      user_attributes: [ :id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio, :profile_image, :delete_profile_image, :cover_image,  location_attributes: [
        :id, :location_search, :city, :state, :country, :_destroy
      ] ]
    )
  end
end
