class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_role, only: %i[ show edit update destroy ]
  before_action :authorize_resource, only: %i[show edit update destroy]
  # GET /roles or /roles.json
  def index
    if params[:query].present?
      @pagy, @roles = pagy(Role.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @roles = pagy(Role.all, limit: params[:per_page] || "10")
    end
    authorize @roles
  end

  # GET /roles/1 or /roles/1.json
  def show
  end

  # GET /roles/new
  def new
    @role = Role.new
  end

  # GET /roles/1/edit
  def edit
  end

  # POST /roles or /roles.json
  def create
    @role = Role.new(role_params)
    respond_to do |format|
      if @role.save
        flash[:notice] = "Role was successfully created."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @role, notice: "Role was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def bulk_destroy
    resource_ids = bulk_delete_params[:resource_ids] # Extract entry_ids from params
    respond_to do |format|
      if resource_ids.present?
        # Destroy roles matching the provided entry_ids
        Role.where(id: resource_ids).destroy_all
        format.html { redirect_to roles_path, notice: "Role was successfully destroyed." }
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles/1 or /roles/1.json
  def update
    respond_to do |format|
      if @role.update(role_params)
        flash[:notice] = "Role was successfully updated."
        format.html { redirect_to @role, notice: "Role was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.json { render :show, status: :ok, location: @role }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1 or /roles/1.json
  def destroy
    @role.destroy!

    respond_to do |format|
      format.html { redirect_to roles_path, status: :see_other, notice: "Role was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params.expect(:id))
    end

    def authorize_resource
      authorize @role
    end

    def bulk_delete_params
      params.require(:bulk_delete).permit(resource_ids: [])
    end

    # Only allow a list of trusted parameters through.
    def role_params
      params.expect(role: [ :name, :is_default ])
    end
end
