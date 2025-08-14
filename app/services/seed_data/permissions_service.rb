# frozen_string_literal: true

module SeedData
  class PermissionsService < BaseService
    PERMISSIONS = [
      { name: "Users", resource: "User" },
      { name: "Roles", resource: "Role" },
      { name: "RolePermissions", resource: "RolePermission" },
      { name: "Permissions", resource: "Permission" },
      { name: "Categories", resource: "Category" },
      { name: "Job", resource: "Job" },
      { name: "JobApplication", resource: "JobApplication" },
      { name: "JobBoardIntegration", resource: "JobBoardIntegration" },
      { name: "JobBoardProvider", resource: "JobBoardProvider" },
      { name: "JobBoardSyncLog", resource: "JobBoardSyncLog" },
    ].freeze

    def call
      create_permissions
    end

    private

    def create_permissions
      log "Creating Permissions..."

      PERMISSIONS.each do |perm|
        Permission.find_or_create_by!(name: perm[:name], resource: perm[:resource])
      end

      log "Permissions created: #{PERMISSIONS.map { |p| p[:name] }.join(', ')}"
    end
  end
end
