class CandidatesController < ApplicationController
  before_action :set_candidate, only: %i[ show edit update ]

  def index
  end
  def show
  end
  def edit
  end

  def update
    respond_to do |format|
      if @candidate.update(candidate_params)
        flash[:notice] = "Profile was successfully updated."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to candidate_path(@candidate), notice: "Profile was successfully updated." }
      else
        flash.now[:alert] = @candidate.errors.full_messages.join(", ")
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("candidate_profile_personal_info", partial: "candidates/personal_info_form", locals: { candidate: @candidate })
          ], status: :unprocessable_entity
        }
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
   end

  def set_candidate
    @candidate = current_user.candidate
  end

  private
  def candidate_params
    params.require(:candidate).permit(
      user_attributes: [:id, :first_name, :last_name, :phone_number, :gender, :date_of_birth, :email_required]
    )
  end
end