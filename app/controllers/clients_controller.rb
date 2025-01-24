class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[ show edit update destroy ]

  def index
    if params[:query].present?
      @pagy, @clients = pagy(Client.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @clients = pagy(Client.all, limit: params[:per_page] || "10")
    end
  end

  def show
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)

    respond_to do |format|
      if @client.save
        flash[:notice] =  "Client was successfully created."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @client, notice: "Client was successfully created." }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        flash[:notice] =  "Client was successfully updated."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @client, notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.destroy!

    respond_to do |format|
      format.html { redirect_to client_path, status: :see_other, notice: "Client was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def bulk_destroy
    resource_ids = bulk_delete_params[:resource_ids] # Extract entry_ids from params
    respond_to do |format|
      if resource_ids.present?
        # Destroy roles matching the provided entry_ids
        Client.where(id: resource_ids).destroy_all
        format.html { redirect_to roles_path, notice: "Client was successfully destroyed." }
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
    def set_client
      @client = Client.find(params.expect(:id))
    end

    def authorize_resource
      authorize @client
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.expect(client: [ :name, :subdomain])
    end
end
