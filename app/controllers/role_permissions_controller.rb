class RolePermissionsController < ApplicationController
  before_action :set_role_permission, only: %i[ show edit update destroy ]

  # GET /role_permissions or /role_permissions.json
  def index
    @role_permissions = RolePermission.all
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
  end

  # POST /role_permissions or /role_permissions.json
  def create
    @role_permission = RolePermission.new(role_permission_params)

    respond_to do |format|
      if @role_permission.save
        format.html { redirect_to @role_permission, notice: "Role permission was successfully created." }
        format.json { render :show, status: :created, location: @role_permission }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @role_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /role_permissions/1 or /role_permissions/1.json
  def update
    respond_to do |format|
      if @role_permission.update(role_permission_params)
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role_permission
      @role_permission = RolePermission.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def role_permission_params
      params.expect(role_permission: [ :role_id, :permission_id ])
    end
end
