class CompaniesController < ApplicationController
  before_action :set_company, only: [ :update ]
  def index
  end

  def new
    @company = current_user.company.new
  end

  def show
  end

  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        # Assign the current user to the company without validation
        current_user.update_column(:company_id, @company.id)

        # If user is in onboarding, update their user type and company association
        if current_user&.needs_onboarding?
          SeedData::UserRoleAssigner.call(current_user, @company)
          format.html { redirect_to profile_setup_onboarding_path, notice: "Company was successfully created." }
          format.turbo_stream { redirect_to profile_setup_onboarding_path, notice: "Company was successfully created." }
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

  def update
     company.avatar.purge if should_purge_avatar?
     respond_to do |format|
      if @company.update(company_params)
        # If user is in onboarding, update their user type and company association
        flash[:notice] = "Your company has been updated successfully."
        if current_user&.needs_onboarding?
          format.html { redirect_to profile_setup_onboarding_path, notice: "Company was successfully saved." }
          format.turbo_stream { redirect_to profile_setup_onboarding_path, notice: "Company was successfully saved." }
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
          flash[:alert] = @company.errors.full_messages.join(", ")
          format.html { redirect_to request.referrer, alert: @company.errors.full_messages.join(", ") }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  protected

  def should_purge_avatar?
    company_params[:delete_avatar_image] == "1" &&
      company_params[:delete_avatar_image].blank?
  end

  def set_company
    @company = current_user.company
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.require(:company).permit(
      :name, :subdomain, :website, :redirect_to, :delete_avatar_image, :avatar, :description
    )
  end
end
