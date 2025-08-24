class JobBoardFieldMappingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_job_board_integration
  before_action :set_job_board_field_mapping, only: [ :edit, :update, :destroy ]
  before_action :ensure_company_access

  def index
    @field_mappings = @job_board_integration.job_board_field_mappings.ordered
    @available_local_fields = available_local_fields
    @available_external_fields = available_external_fields
  end

  def create
    @field_mapping = @job_board_integration.job_board_field_mappings.build(field_mapping_params)

    if @field_mapping.save
      respond_to do |format|
        format.html { redirect_to job_board_integration_job_board_field_mappings_path(@job_board_integration), notice: "Field mapping was successfully created." }
        format.json { render json: { success: true, message: "Field mapping created successfully" } }
      end
    else
      respond_to do |format|
        format.html do
          @field_mappings = @job_board_integration.job_board_field_mappings.ordered
          @available_local_fields = available_local_fields
          @available_external_fields = available_external_fields
          render :index, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @field_mapping.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.json { render json: @field_mapping }
    end
  end

  def update
    if @field_mapping.update(field_mapping_params)
      respond_to do |format|
        format.html { redirect_to job_board_integration_job_board_field_mappings_path(@job_board_integration), notice: "Field mapping was successfully updated." }
        format.json { render json: { success: true, message: "Field mapping updated successfully" } }
      end
    else
      respond_to do |format|
        format.html do
          @field_mappings = @job_board_integration.job_board_field_mappings.ordered
          @available_local_fields = available_local_fields
          @available_external_fields = available_external_fields
          render :index, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @field_mapping.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @field_mapping.destroy
    redirect_to job_board_integration_job_board_field_mappings_path(@job_board_integration),
                notice: "Field mapping was successfully deleted."
  end

  private

  def set_company
    @company = current_user.company
    redirect_to root_path, alert: "Company not found." unless @company
  end

  def set_job_board_integration
    @job_board_integration = @company.job_board_integrations.find(params[:job_board_integration_id])
  end

  def set_job_board_field_mapping
    @field_mapping = @job_board_integration.job_board_field_mappings.find(params[:id])
  end

  def field_mapping_params
    params.require(:job_board_field_mapping).permit(
      :local_field, :external_field, :field_type, :is_required, :default_value
    )
  end

  def available_local_fields
    [
      "title", "description", "location", "salary_min", "salary_max", "salary_currency",
      "job_type", "experience_level", "remote_work", "company_name", "company_description",
      "company_website", "application_url", "created_at", "updated_at", "expires_at", "status"
    ]
  end

  def available_external_fields
    @job_board_integration.provider_info&.supported_fields || []
  end

  def ensure_company_access
    unless current_user.company_user? && current_user.company == @company
      redirect_to root_path, alert: "Access denied."
    end
  end
end
