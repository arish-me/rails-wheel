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
    tab = params[:tab] || 'personal'
    #respond_to do |format|
      if @candidate.update(candidate_params_for_tab(tab))
        if turbo_frame_request?
          next_tab = case tab
                     when 'personal' then 'professional'
                     when 'professional' then 'work'
                     else nil
                     end
          debugger
          if next_tab
            render partial: "candidates/form/tab_panel_#{next_tab}", locals: { candidate: @candidate }, layout: false, status: :ok
          else
            flash.now[:notice] = "Profile updated!"
            render partial: "candidates/form/tab_panel_#{tab}", locals: { candidate: @candidate }, layout: false, status: :ok
          end
        else
          redirect_to @candidate, notice: "Profile updated!"
        end
      else
        if turbo_frame_request?
          render partial: "candidates/form/tab_panel_#{tab}", locals: { candidate: @candidate }, layout: false, status: :unprocessable_entity
        else
          render :edit
        end
      end
    #end
  end

def candidate_params_for_tab(tab)
  case tab
  when 'personal'
    params.require(:candidate).permit(user_attributes: [ :id, :first_name, :last_name, :gender, :phone_number, :date_of_birth, :bio ])
  when 'professional'
    params.require(:candidate).permit(profile_attributes: [ :id, :headline ])
  when 'work'
    params.require(:candidate).permit(work_preference_attributes: [ :id, :search_status, :role_type, :role_level, :_destroy ], role_type_attributes: RoleType::TYPES, role_level_attributes: RoleLevel::TYPES)
  when 'social'
    params.require(:candidate).permit(profile_attributes: [ :id, :linkedin, :twitter, :github, :website ])
  else
    candidate_params
  end
end

  def edit
    @candidate.build_profile unless @candidate.profile
    @candidate.build_user unless @candidate.user
    @candidate.build_work_preference unless @candidate.work_preference
    @candidate.build_role_type unless @candidate.role_type
    @candidate.build_role_level unless @candidate.role_level
  end

# def update
#   if @candidate.update(candidate_params)
#     redirect_to @candidate, notice: "Profile updated!"
#   else
#     render :edit
#   end
# end

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
