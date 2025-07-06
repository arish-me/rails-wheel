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
    @profile.build_location unless @candidate.location
  end

  # def update
  #   if @profile.update(profile_params)
  #     redirect_to candidate_profile_path(@candidate, @profile), notice: "Profile was successfully updated."
  #   else
  #     render :edit, status: :unprocessable_entity
  #   end
  # end

  def update
    respond_to do |format|
      if @profile.update(profile_params)
        flash[:notice] =  "Profile was successfully updated."
        # format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to candidate_profile_path(@candidate, @profile), notice: "Profile was successfully updated." }

      else
        flash[:alert] = @profile.errors.full_messages.join(", ")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
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
end
