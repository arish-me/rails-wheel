class Candidates::WorkPreferencesController < ApplicationController
  before_action :set_candidate
  before_action :set_work_preference, only: [ :show, :edit, :update, :destroy ]
  def index
  end
  def edit
  end
  def show
  end

  def create
    @work_preference = @candidate.build_work_preference(work_preference_params)
    respond_to do |format|
      if @work_preference.save
        flash[:notice] =  "Profile was successfully updated."
        # format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to edit_candidate_work_preference_path(@candidate, @work_preference), notice: "Profile was successfully updated." }
      else
        flash[:alert] = @work_preference.errors.full_messages.join(", ")
        format.html { redirect_to edit_candidate_work_preference_path(@candidate, @work_preference)}
        format.json { render json: @work_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @work_preference.update(work_preference_params)
        flash[:notice] =  "Profile was successfully updated."
        # format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to edit_candidate_work_preference_path(@candidate), notice: "Profile was successfully updated." }

      else
        flash[:alert] = @work_preference.errors.full_messages.join(", ")
        format.html { redirect_to edit_candidate_work_preference_path(@candidate)}
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  def set_candidate
    @candidate = Candidate.find(params[:candidate_id])
  end

  def set_work_preference
    @work_preference = @candidate.work_preference || @candidate.build_work_preference
  end

  def work_preference_params
    params.require(:candidate_work_preference).permit(:search_status)
  end
end