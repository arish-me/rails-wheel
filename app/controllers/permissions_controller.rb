class PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_permission, only: %i[ show edit update destroy ]
  before_action :authorize_resource, only: %i[show edit update destroy]
  # GET /permissions or /permissions.json
  def index
    if params[:query].present?
      @pagy, @permissions = pagy(Permission.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @permissions = pagy(Permission.all, limit: params[:per_page] || "10")
    end
    authorize @permissions
  end

  # GET /permissions/1 or /permissions/1.json
  def show
  end

  # GET /permissions/new
  def new
    @permission = Permission.new
  end

  # GET /permissions/1/edit
  def edit
  end

  # POST /permissions or /permissions.json
  def create
    @permission = Permission.new(permission_params)

    respond_to do |format|
      if @permission.save
        flash[:notice] =  "Permission was successfully created."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @permission, notice: "Permission was successfully created." }
        format.json { render :show, status: :created, location: @permission }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  def bulk_destroy
    resource_ids = bulk_delete_params[:resource_ids] # Extract entry_ids from params
    respond_to do |format|
      if resource_ids.present?
        # Destroy roles matching the provided entry_ids
        Permission.where(id: resource_ids).destroy_all
        format.html { redirect_to roles_path, notice: "Permission was successfully destroyed." }
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permissions/1 or /permissions/1.json
  def update
    respond_to do |format|
      if @permission.update(permission_params)
        flash[:notice] =  "Permission was successfully updated."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @permission, notice: "Permission was successfully updated." }
        format.json { render :show, status: :ok, location: @permission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permissions/1 or /permissions/1.json
  def destroy
    @permission.destroy!

    respond_to do |format|
      format.html { redirect_to permissions_path, status: :see_other, notice: "Permission was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def bulk_delete_params
      params.require(:bulk_delete).permit(resource_ids: [])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_permission
      @permission = Permission.find(params.expect(:id))
    end

    def authorize_resource
      authorize @permission
    end

    # Only allow a list of trusted parameters through.
    def permission_params
      params.expect(permission: [ :name, :resource ])
    end
end
