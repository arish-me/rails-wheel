class Candidates::WorkPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate
  before_action :set_work_preference, only: [:show, :edit, :update, :destroy]

  def index
  end

  def edit
    # Ensure role associations exist
    @work_preference.ensure_role_associations
  end

  def show
    # Ensure role associations exist
    @work_preference.ensure_role_associations
  end

  def create
    @work_preference = @candidate.build_work_preference(work_preference_params)
    @work_preference.ensure_role_associations

    respond_to do |format|
      if @work_preference.save
        flash[:notice] = "Work preferences were successfully created."
        format.html { redirect_to candidate_work_preference_path(@candidate), notice: "Work preferences were successfully created." }
      else
        format.html { render :edit }
        format.json { render json: @work_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @work_preference.update(work_preference_params)
        flash[:notice] =  "Work preferences was successfully updated."
        format.html { redirect_to candidate_work_preference_path(@candidate), notice: "Work preferences were successfully created." }
      else
        flash[:alert] = @work_preference.errors.full_messages.join(", ")
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @work_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  private

  def set_candidate
    @candidate = Candidate.find(params[:candidate_id])
  end

  def set_work_preference
    @work_preference = @candidate.work_preference || @candidate.build_work_preference
  end

  def work_preference_params
    params.require(:candidate_work_preference).permit(
      :search_status,
      role_type_attributes: [:id, :part_time_contract, :full_time_contract, :full_time_employment],
      role_level_attributes: [:id, :junior, :mid, :senior, :principal, :c_level]
    )
  end
end
