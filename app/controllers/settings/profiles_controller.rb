module Settings
  class ProfilesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_or_initialize_profile, only: [ :edit, :update, :update_avatar, :delete_avatar, :update_theme ]
    skip_before_action :verify_authenticity_token, only: [ :update_avatar, :delete_avatar, :update_theme ]

    # GET /profiles/1/edit
    def edit
      # The `@profile` will either be an existing profile or a new instance
    end

    # PATCH/PUT /profiles/1
    def update
      respond_to do |format|
        if update_profile
          @profile.avatar.purge if should_purge_profile_image?
          flash[:notice] =  "Profile was successfully updated."
          format.html { redirect_to edit_settings_profile_path }
          format.json { render :edit, status: :ok, location: @profile }
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @profile.errors, status: :unprocessable_entity }
          format.turbo_stream { render :edit, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /profiles/1/update_avatar
    def update_avatar
      # Handle both normal form submissions and AJAX/JSON requests
      blob_id = params[:profile] && params[:profile][:avatar_blob_id] ||
                params[:avatar_blob_id]

      if blob_id.present?
        # Find the blob
        blob = ActiveStorage::Blob.find_signed(blob_id)

        # Purge any existing avatar
        @profile.avatar.purge if @profile.avatar.attached?

        # Attach the new blob
        @profile.avatar.attach(blob)

        # Respond based on the request format
        respond_to do |format|
          format.html { redirect_to edit_settings_profile_path, notice: "Avatar updated successfully" }
          format.json { render json: { success: true, avatar_url: url_for(@profile.avatar.variant(:thumbnail)) } }
          format.turbo_stream # Will render update_avatar.turbo_stream.erb
        end
      else
        respond_to do |format|
          format.html { redirect_to edit_settings_profile_path, alert: "No avatar provided" }
          format.json { render json: { success: false, error: "No avatar blob ID provided" }, status: :unprocessable_entity }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("avatar_error", partial: "shared/flash", locals: { type: "error", message: "No avatar provided" }) }
        end
      end
    end

    # DELETE /profiles/1/delete_avatar
    def delete_avatar
      if @profile.avatar.attached?
        @profile.avatar.purge

        respond_to do |format|
          format.html { redirect_to edit_settings_profile_path, notice: "Avatar removed successfully" }
          format.json { render json: { success: true } }
          format.turbo_stream # Will render delete_avatar.turbo_stream.erb
        end
      else
        respond_to do |format|
          format.html { redirect_to edit_settings_profile_path, alert: "No avatar to remove" }
          format.json { render json: { success: false, error: "No avatar attached" }, status: :unprocessable_entity }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("avatar_error", partial: "shared/flash", locals: { type: "error", message: "No avatar to remove" }) }
        end
      end
    end

    # PATCH/PUT /profiles/1/update_theme
    def update_theme
      theme = params[:theme]

      if theme.present? && Profile.theme_preferences.keys.include?(theme)
        @profile.update(theme_preference: theme)
        session[:theme] = theme

        respond_to do |format|
          format.html { redirect_to edit_settings_profile_path, notice: "Theme updated successfully" }
          format.json { render json: { success: true, theme: theme } }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("theme_message", partial: "shared/flash", locals: { type: "success", message: "Theme updated successfully" }) }
        end
      else
        respond_to do |format|
          format.html { redirect_to edit_settings_profile_path, alert: "Invalid theme preference" }
          format.json { render json: { success: false, error: "Invalid theme preference" }, status: :unprocessable_entity }
          format.turbo_stream { render turbo_stream: turbo_stream.replace("theme_message", partial: "shared/flash", locals: { type: "error", message: "Invalid theme preference" }) }
        end
      end
    end

    private

      # Find the profile or build a new one for the current user
      def set_or_initialize_profile
        @profile = Profile.find_or_initialize_by(user_id: current_user.id)
      end

      def update_profile
        result = @profile.update(profile_params.except(:delete_avatar))

        # Update theme preference in user's session if it changed
        if result && @profile.saved_change_to_theme_preference?
          session[:theme] = @profile.theme_preference
        end

        result
      end

      def should_purge_profile_image?
        profile_params[:delete_avatar] == "1" &&
          profile_params[:avatar].blank?
      end

      # Only allow a list of trusted parameters through.
      def profile_params
        params.require(:profile).permit(
          :first_name,
          :middle_name,
          :last_name,
          :gender,
          :bio,
          :avatar,
          :avatar_blob_id,
          :delete_avatar,
          :phone_number,
          :date_of_birth,
          :location,
          :website,
          :social_links,
          :theme_preference,
          :timezone,
          :country_code,
          :postal_code
        )
      end
  end
end
