module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_resource, only: %i[index show edit update destroy]
    before_action :set_user, only: %i[show edit update destroy]

    before_action :set_tenent

    def index
      if params[:query].present?
        @pagy, @users = pagy(User.search_by_email(params[:query]), limit: params[:per_page] || "10")
      else
        @pagy, @users = pagy(ActsAsTenant.current_tenant.users.all, limit: params[:per_page] || "10")
      end
      authorize @users
    end

    def set_tenent
      return if current_user.user?

      ActsAsTenant.current_tenant = current_user.company
    end

    def show; end

    def new
      @user = User.new
    end

    def edit; end

    def create
      @user = User.new(user_params)
      @user.skip_password_validation = true
      @user.onboarded_at = Time.now.utc
      @user.assign_default_role
      @user.user_type = "company"
      @user.company_id = ActsAsTenant.current_tenant.id
      respond_to do |format|
        if @user.save
          flash[:notice] = "User was successfully created."
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
          format.html { redirect_to @user, notice: "User was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def bulk_destroy
      resource_ids = bulk_delete_params[:resource_ids] # Extract entry_ids from params
      respond_to do |format|
        if resource_ids.present?
          User.where(id: resource_ids).destroy_all
          format.html { redirect_to users_path, notice: "User was successfully destroyed." }
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        @user.skip_password_validation = true
        lock_user
        # update_roles(@user)
        if @user.update(user_params)
          flash[:notice] = "User was successfully updated."
          format.html { redirect_to @user, notice: "User was successfully updated." }
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /roles/1 or /roles/1.json
    def destroy
      @user.destroy!

      respond_to do |format|
        format.html { redirect_to users_path, status: :see_other, notice: "User was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    def impersonate
      authorize current_user

      user = User.find(params[:id])
      impersonate_user(user)
      redirect_to root_path
    end

    def stop_impersonating
      stop_impersonating_user
      redirect_to root_path
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    def bulk_delete_params
      params.expect(bulk_delete: [ resource_ids: [] ])
    end

    def authorize_resource
      authorize current_user
    end

    def update_roles(user)
      user.roles = Role.where(id: params[:user][:role_ids].compact_blank)
    end

    def lock_user
      if params[:locked] == "1"
        @user.lock_access! unless @user.access_locked?
      elsif @user.access_locked?
        @user.unlock_access!
      end
    end

    def user_params
      params.expect(
        user: [ :email,
               :locked,
               :first_name, :last_name, :gender,
               { role_ids: [] } ] # This allows multiple role IDs to be assigned
      )
    end
  end
end
