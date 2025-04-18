# frozen_string_literal: true

module SeedData
  class RolePermissionsService < BaseService
    ADMIN_ROLES = [ "SuperAdmin" ].freeze

    def call
      assign_permissions_to_admin_roles
    end

    private

    def assign_permissions_to_admin_roles
      permissions = Permission.all

      ADMIN_ROLES.each do |role_name|
        log "Assigning All Permissions to #{role_name} Role..."
        role = Role.find_by(name: role_name)

        permissions.each do |permission|
          RolePermission.find_or_create_by!(
            role: role,
            permission: permission,
            action: RolePermission.actions[:edit]
          )
        end

        log "#{role_name} now has all permissions with edit access."
      end
    end
  end
end
