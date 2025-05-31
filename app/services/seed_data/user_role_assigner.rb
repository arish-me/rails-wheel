# app/services/seed_data/user_role_assigner.rb
module SeedData
  class UserRoleAssigner < BaseService
    def initialize(user, company)
      @user = user
      @company = company
    end

    def call
      log "Attempting to assign SuperAdmin role to user #{@user.email} for company #{@company.name} (ID: #{@company.id})..."

      # Ensure we operate within the correct tenant context for finding the role
      ActsAsTenant.with_tenant(@company) do
        super_admin_role = Role.find_by(name: "SuperAdmin")

        if super_admin_role
          # Assign the role to the user for this company
          # Assuming UserRole model links User, Role, and Company
          user_role = UserRole.find_or_create_by!(user: @user, role: super_admin_role, company: @company)
          log "SuperAdmin role assigned to user #{@user.email} for company #{@company.name}. UserRole ID: #{user_role.id}"
        else
          log "Error: SuperAdmin role not found for company #{@company.name}. Cannot assign."
        end
      end
    rescue => e
      log "Failed to assign SuperAdmin role: #{e.message}"
      # Optionally re-raise or handle the error more gracefully
    end
  end
end