class CompaniesController < ApplicationController
  before_action :set_company, only: [:update]
  def index
  end

  def new
    @company = Company.new
  end

  def show
  end

  def create
    @company = Company.new(company_params)
    respond_to do |format|
      if @company.save
        # If user is in onboarding, update their user type and company association
        if current_user&.needs_onboarding?
          current_user.update!(
            company_id: @company.id
          )
          SeedData::UserRoleAssigner.call(current_user, @company)
          format.html { redirect_to preferences_onboarding_path, notice: "Company was successfully created." }
          format.turbo_stream { redirect_to preferences_onboarding_path, notice: "Company was successfully created." }
        else
          format.html { redirect_to @company, notice: "Company was successfully created." }
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        end
        format.json { render :show, status: :created, location: @company }
      else
        if current_user&.needs_onboarding?
          format.html { redirect_to onboarding_path, alert: @company.errors.full_messages.join(", ") }
          format.turbo_stream { redirect_to onboarding_path, alert: @company.errors.full_messages.join(", ") }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
     respond_to do |format|
      if @company.update(company_params)
        # If user is in onboarding, update their user type and company association
        if current_user&.needs_onboarding?
          format.html { redirect_to preferences_onboarding_path, notice: "Company was successfully saved." }
          format.turbo_stream { redirect_to preferences_onboarding_path, notice: "Company was successfully saved." }
        else
          format.html { redirect_to @company, notice: "Company was successfully created." }
          format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        end
        format.json { render :show, status: :created, location: @company }
      else
        debugger
        if current_user&.needs_onboarding?
          format.html { redirect_to onboarding_path, alert: @company.errors.full_messages.join(", ") }
          format.turbo_stream { redirect_to onboarding_path, alert: @company.errors.full_messages.join(", ") }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def set_company
    @company = current_user.company
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.require(:company).permit(:name, :subdomain, :website)
  end
end
