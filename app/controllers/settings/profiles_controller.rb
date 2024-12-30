module Settings
  class ProfilesController < ApplicationController
    before_action :set_or_initialize_profile, only: [:edit, :update]

    # GET /profiles/1/edit
    def edit
      # The `@profile` will either be an existing profile or a new instance
    end

    # PATCH/PUT /profiles/1
    def update
      respond_to do |format|
        if @profile.update(profile_params)
          format.html { redirect_to edit_settings_profile_path, notice: "Profile was successfully updated." }
          format.json { render :edit, status: :ok, location: @profile }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @profile.errors, status: :unprocessable_entity }
        end
      end
    end

    private

      # Find the profile or build a new one for the current user
      def set_or_initialize_profile
        @profile = Profile.find_or_initialize_by(user_id: current_user.id)
      end

      # Only allow a list of trusted parameters through.
      def profile_params
        params.require(:profile).permit(:first_name, :middle_name, :last_name, :gender, :bio)
      end
  end
end
