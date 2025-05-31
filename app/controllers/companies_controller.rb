class CompaniesController < ApplicationController
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
        format.html { redirect_to @company, notice: "Company was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.refresh(request_id: nil) }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.require(:company).permit(:name, :subdomain, :website)
  end
end
