class RolePermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_role_permission, only: %i[ show update destroy ]
  # before_action :authorize_resource, only: %i[show edit update destroy]

  # GET /role_permissions or /role_permissions.json
  def index
    if params[:query].present?
      @pagy, @role_permissions = pagy(RolePermission.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @roles = Role.all
      @pagy, @role_permissions = pagy(RolePermission.all, limit: params[:per_page] || "10")
    end
    authorize @role_permissions
  end

  # GET /role_permissions/1 or /role_permissions/1.json
  def show
  end

  # GET /role_permissions/new
  def new
    @role_permission = RolePermission.new
  end

  # GET /role_permissions/1/edit
  def edit
    @role = Role.find(params[:id])
    @permissions = Permission.all
    @role_permission = RolePermission.new

    authorize @role_permission
  end

  def create
    role_id = params[:role_id]
    permissions = params[:permissions] || {}

    ActiveRecord::Base.transaction do
      permissions.each do |permission_id, action|
        # Delete the RolePermission if "none" is selected
        if action == "none"
          RolePermission.where(role_id: role_id, permission_id: permission_id).destroy_all
        else
          role_permission = RolePermission.find_or_initialize_by(role_id: role_id, permission_id: permission_id)
          role_permission.action = action
          role_permission.save!
        end
      end
    end

    respond_to do |format|
      flash[:notice] = "Permissions assigned successfully."
      format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      format.html { redirect_to roles_path, notice: "Permissions updated successfully." }
    end
    rescue StandardError => e
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Failed to assigned permissions: #{e.message}"
          format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /role_permissions/1 or /role_permissions/1.json
  def update
    respond_to do |format|
      if @role_permission.update(role_permission_params)
        flash[:notice] =  "Role permission was successfully created."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @role_permission, notice: "Role permission was successfully updated." }
        format.json { render :show, status: :ok, location: @role_permission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @role_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /role_permissions/1 or /role_permissions/1.json
  def destroy
    @role_permission.destroy!

    respond_to do |format|
      format.html { redirect_to role_permissions_path, status: :see_other, notice: "Role permission was successfully destroyed." }
      format.json { head :no_content }
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

  private

    def bulk_delete_params
      params.require(:bulk_delete).permit(resource_ids: [])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_role_permission
      @role_permission = RolePermission.find(params.expect(:id))
    end

    def authorize_resource
      authorize @role_permission
    end

    # Only allow a list of trusted parameters through.
    def role_permission_params
      params.expect(role_permission: [ :role_id, :permission_id, :action ])
    end
end
