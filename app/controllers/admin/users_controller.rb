class Admin::UsersController < ApplicationController
   before_action :set_user, only: %i[ show edit update destroy ]

  def index
    if params[:query].present?
      @pagy, @users = pagy(User.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @users = pagy(User.all, limit: params[:per_page] || "10")
    end
  end


  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.skip_password_validation = true
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
      if @user.update(user_params)
        flash[:notice] = 'User was successfully updated.'
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    def bulk_delete_params
      params.require(:bulk_delete).permit(resource_ids: [])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :email ])
    end
end
