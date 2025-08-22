class CandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate, only: %i[show edit update]

  def index
    @profile = @candidate&.profile ? @candidate.profile : @candidate.build_profile
  end

  def show
    @profile = @candidate.profile || @candidate.build_profile
  end

  def edit; end

  def update
    respond_to do |format|
      if @candidate.update(candidate_params)
        flash[:notice] = 'Profile was successfully updated.'
        format.html {}
      else
        flash[:alert] = @candidate.errors.full_messages.join(', ')
        if current_user.onboarded?
          format.html { render :edit, status: :unprocessable_entity }
        else
          format.html { render 'onboardings/show', status: :unprocessable_entity }
        end
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_candidate
    @candidate = current_user.candidate
    @user = current_user
  end

  def candidate_params
    params.expect(
      candidate: [:redirect_to, :onboarding_preferences,
                  { user_attributes: [:id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio, :avatar, :delete_profile_image, :cover_image, { location_attributes: %i[location_search city state country id] }] }]
    )
  end

  # def candidate_params
  #   params.require(:candidate).permit(
  #     profile_attributes: [ :id, :headline, :candidate_role_id, :experience, :_destroy ],
  #     user_attributes: [ :id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio, :avatar, :delete_profile_image, :cover_image ],
  #     work_preference_attributes: [ :id, :search_status ],
  #     social_link_attributes: [ :id, :github, :website, :linked_in, :twitter, :_destroy ],
  #     location_attributes: [ :city, :state, :country_code ]
  #   )
  # end
end
