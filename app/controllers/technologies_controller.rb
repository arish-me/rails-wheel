class TechnologiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_technology, only: %i[ show edit update destroy ]
  before_action :authorize_resource, only: %i[show edit update destroy]

  # GET /technologies or /technologies.json
  def index
    if params[:query].present?
      @pagy, @technologies = pagy(Technology.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @technologies = pagy(Technology.all, limit: params[:per_page] || "10")
    end
  end

  # GET /technologies/1 or /technologies/1.json
  def show
  end

  # GET /technologies/new
  def new
    @technology = Technology.new
  end

  # GET /technologies/1/edit
  def edit
  end

  # POST /technologies or /technologies.json
  def create
    @technology = Technology.new(technology_params)

    respond_to do |format|
      if @technology.save
        flash[:notice] =  "Technology was successfully created."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @technology, notice: "Technology was successfully created." }
        format.json { render :show, status: :created, location: @technology }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /technologies/1 or /technologies/1.json
  def update
    respond_to do |format|
      if @technology.update(technology_params)
        flash[:notice] =  "Technology was successfully updated."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @technology, notice: "Technology was successfully updated." }
        format.json { render :show, status: :ok, location: @technology }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technologies/1 or /technologies/1.json
  def destroy
    @technology.destroy!

    respond_to do |format|
      format.html { redirect_to technologies_path, status: :see_other, notice: "Technology was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def bulk_destroy
    resource_ids = bulk_delete_params[:resource_ids] # Extract entry_ids from params
    respond_to do |format|
      if resource_ids.present?
        Technology.where(id: resource_ids).destroy_all
        format.html { redirect_to roles_path, notice: "Technology was successfully destroyed." }
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end


  private

    def authorize_resource
      authorize @technology
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_technology
      @technology = Technology.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def technology_params
      params.expect(technology: [ :name, :subtitle, :description, :course_id ])
    end
end
