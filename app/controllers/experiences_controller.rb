class ExperiencesController < ApplicationController
  before_action :set_candidate
  before_action :set_experience, only: [ :edit, :update, :destroy ]

  def new
    @experience = @candidate.experiences.build
    render partial: "candidates/edit/experience", locals: { experience: @experience, candidate: @candidate }
  end

  def create
    @experience = @candidate.experiences.build(experience_params)
    if @experience.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to candidate_path(@candidate), notice: "Experience added successfully." }
      end
    else
      render partial: "candidates/edit/experience", locals: { experience: @experience, candidate: @candidate }, status: :unprocessable_entity
    end
  end

  def edit
    render partial: "candidates/edit/experience", locals: { experience: @experience, candidate: @candidate }
  end

  def update
    if @experience.update(experience_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to candidate_path(@candidate), notice: "Experience updated successfully." }
      end
    else
      render partial: "candidates/edit/experience", locals: { experience: @experience, candidate: @candidate }, status: :unprocessable_entity
    end
  end

  def destroy
    @experience.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      format.html { redirect_to candidate_path(@candidate), notice: "Experience deleted successfully." }
    end
  end

  private
  def set_candidate
    @candidate = current_user.candidate
  end

  def set_experience
    @experience = @candidate.experiences.find(params[:id])
  end

  def experience_params
    params.require(:experience).permit(:company_name, :job_title, :start_date, :end_date, :current_job, :description)
  end
end
