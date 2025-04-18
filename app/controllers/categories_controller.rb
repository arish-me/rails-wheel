class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[ show edit update destroy ]
  before_action :authorize_resource, only: %i[show edit update destroy]

  # GET /categories or /categories.json
  def index
    if params[:query].present?
      @pagy, @categories = pagy(current_user.categories.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @categories = pagy(current_user.categories, limit: params[:per_page] || "10")
    end
    authorize @categories
  end

  # GET /categories/1 or /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = current_user.categories.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    @category = current_user.categories.new(category_params)

    respond_to do |format|
      if @category.save
        flash[:notice] =  "Category was successfully created."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @category, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        flash[:notice] =  "Category was successfully updated."
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.html { redirect_to @category, notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to categories_path, status: :see_other, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def bulk_destroy
    resource_ids = bulk_delete_params[:resource_ids] # Extract entry_ids from params
    respond_to do |format|
      if resource_ids.present?
        # Destroy roles matching the provided entry_ids
        Category.where(id: resource_ids).destroy_all
        format.html { redirect_to roles_path, notice: "Category was successfully destroyed." }
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
    def set_category
      @category = Category.find(params.expect(:id))
    end

    def authorize_resource
      authorize @category
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.expect(category: [ :name, :description ])
    end
end
