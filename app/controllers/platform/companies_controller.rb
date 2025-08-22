module Platform
  class CompaniesController < Platform::BaseController
    before_action :set_company, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        @pagy, @companies = pagy(Company.search_by_name(params[:query]), limit: params[:per_page] || '10')
      else
        @pagy, @companies = pagy(Company.order(id: :asc), limit: params[:per_page] || '10')
      end

      authorize Company, policy_class: Platform::CompanyPolicy
    end

    def show; end

    def new
      @company = Company.new
      # authorize @company, policy_class: Platform::CompanyPolicy #
    end

    def create
      # authorize @company, policy_class: Platform::CompanyPolicy
      @company = Company.new(company_params)
      @user = User.new(user_params)
      respond_to do |format|
        ActiveRecord::Base.transaction do
          raise ActiveRecord::Rollback unless @company.save

          @user.company_id = @company.id
          @user.user_type = :company
          @user.onboarded_at = Time.now.utc
          raise ActiveRecord::Rollback unless @user.save

          SeedData::UserRoleAssigner.call(@user, @company)

          flash[:notice] = "Company '#{@company.name}' and Point of Contact '#{@user.email}' created successfully."
          format.html { redirect_to platform_companies_path }
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        end
      rescue ActiveRecord::Rollback
        flash.now[:alert] = 'Failed to create company and point of contact. Please check the errors below.'
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT platform/companies/1 or platform/companies/1.json
    def update
      # authorize @company, policy_class: Platform::CompanyPolicy
      respond_to do |format|
        if @company.update(company_params)
          flash[:notice] = 'Company was successfully updated.'
          format.html { redirect_to @company, notice: 'Company was successfully updated.' }
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
          format.json { render :show, status: :ok, location: @company }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      #  authorize @company, policy_class: Platform::CompanyPolicy
      @company.destroy!

      respond_to do |format|
        format.html { redirect_to users_path, status: :see_other, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.expect(company: %i[name subdomain website])
    end

    # Define strong parameters for the nested user attributes
    def user_params
      params.require(:company).require(:point_of_contact_user).permit(:email, :password, :password_confirmation)
    end
  end
end
