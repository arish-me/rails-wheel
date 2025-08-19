class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [ :destroy ]
  before_action :authorize_note_access, only: [ :destroy ]

  # ============================================================================
  # ACTIONS
  # ============================================================================

  def index
    @notetable = find_notetable
    @notes = @notetable.notes.includes(:user).order(created_at: :desc)
    @notable_id = @notetable.id
    @notable_type = @notetable.class.name

    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @notes }
    end
  end

  def new
    @notetable = find_notetable
    @note = @notetable.notes.build
    @notable_id = @notetable.id
    @notable_type = @notetable.class.name
  end

  def create
    @notetable = find_notetable
    @note = @notetable.notes.build(note_params)
    @note.user = current_user

    respond_to do |format|
      if @note.save
        format.html { redirect_back(fallback_location: company_candidates_path, notice: "Note was successfully added.") }
        format.json { render json: @note, status: :created }
        format.turbo_stream {
          render turbo_stream: [
            # Update modal content
            turbo_stream.replace("notes_count_#{@notetable.id}",
              partial: "notes/count", locals: { notetable: @notetable }),
            turbo_stream.replace("notes_list_#{@notetable.id}",
              partial: "notes/list", locals: { notes: @notetable.notes.includes(:user).order(created_at: :desc) }),
            turbo_stream.update("add_note_form_#{@notetable.id}",
              partial: "notes/form", locals: { notetable: @notetable, note: Note.new }),
            # Update main page content (outside modal)
            turbo_stream.replace("main_notes_count_#{@notetable.id}",
              partial: "notes/count", locals: { notetable: @notetable }),
            turbo_stream.update("modal", partial: "shared/close_modal")
          ]
        }
      else
        format.html { redirect_back(fallback_location: company_candidates_path, alert: "Failed to add note.") }
        format.json { render json: @note.errors, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("add_note_form_#{@notetable.id}",
            partial: "notes/form", locals: { notetable: @notetable, note: @note })
        }
      end
    end
  end

  def destroy
    @note.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: company_candidates_path, notice: "Note was successfully deleted.") }
      format.json { head :no_content }
              format.turbo_stream {
          render turbo_stream: [
            # Update modal content
            turbo_stream.remove("note_#{@note.id}"),
            turbo_stream.replace("notes_count_#{@note.notetable.id}",
              partial: "notes/count", locals: { notetable: @note.notetable }),
            # Update main page content (outside modal)
            turbo_stream.replace("main_notes_count_#{@note.notetable.id}",
              partial: "notes/count", locals: { notetable: @note.notetable }),
            turbo_stream.update("modal", partial: "shared/close_modal")
          ]
        }
    end
  end

  # ============================================================================
  # PRIVATE METHODS
  # ============================================================================

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def find_notetable
    notetable_type = params[:notetable_type]
    notetable_id = params[:notetable_id]

    case notetable_type
    when "JobApplication"
      JobApplication.joins(:job)
                   .where(jobs: { company: current_user.company })
                   .find(notetable_id)
    when "Candidate"
      Candidate.joins(job_applications: :job)
               .where(jobs: { company: current_user.company })
               .find(notetable_id)
    else
      raise ActiveRecord::RecordNotFound, "Invalid notetable type: #{notetable_type}"
    end
  end

  def authorize_note_access
    # Ensure the note belongs to a job application or candidate from the user's company
    case @note.notetable_type
    when "JobApplication"
      unless @note.notetable.job.company == current_user.company
        redirect_to company_candidates_path, alert: "You do not have permission to access this note."
      end
    when "Candidate"
      unless @note.notetable.job_applications.joins(:job).where(jobs: { company: current_user.company }).exists?
        redirect_to company_candidates_path, alert: "You do not have permission to access this note."
      end
    else
      redirect_to company_candidates_path, alert: "Invalid note type."
    end
  end

  def note_params
    params.require(:note).permit(:content)
  end
end
