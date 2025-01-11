class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: %i[ show edit update destroy ]
  before_action :authorize_resource, only: %i[show edit update destroy]
  # GET /roles or /roles.json
  def index
    if params[:query].present?
      @pagy, @accounts = pagy(Account.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @accounts = pagy(Account.all, limit: params[:per_page] || "10")
    end
    authorize @accounts
  end

  # GET /roles/1 or /roles/1.json
  def show
  end

  # GET /roles/new
  def new
    @account = Account.new
  end

  # GET /roles/1/edit
  def edit
  end

  # POST /roles or /roles.json
  def create
    @account = Account.new(account_params)
    respond_to do |format|
      if @account.save
        flash[:notice] = "Account was successfully created."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @account, notice: "Account was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def bulk_destroy
    resource_ids = bulk_delete_params[:resource_ids] # Extract entry_ids from params
    respond_to do |format|
      if resource_ids.present?
        # Destroy roles matching the provided entry_ids
        Account.where(id: resource_ids).destroy_all
        format.html { redirect_to roles_path, notice: "Account was successfully destroyed." }
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles/1 or /roles/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to @account, notice: "Account was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1 or /roles/1.json
  def destroy
    @account.destroy!

    respond_to do |format|
      format.html { redirect_to accounts_path, status: :see_other, notice: "Account was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params.expect(:id))
    end

    def authorize_resource
      authorize @account
    end

    def bulk_delete_params
      params.require(:bulk_delete).permit(resource_ids: [])
    end

    # Only allow a list of trusted parameters through.
    def role_params
      params.expect(account: [ :name, :subdomain, :contact_email ])
    end
end
