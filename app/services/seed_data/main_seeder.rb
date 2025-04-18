# frozen_string_literal: true

module SeedData
  class MainSeeder < BaseService
    def call
      log "Starting database seeding process..."
      seed_roles
      seed_permissions
      seed_role_permissions
      seed_users
      log "Seeding completed successfully!"
    end

    private

    def seed_roles
      SeedData::RolesService.call
    end

    def seed_permissions
      SeedData::PermissionsService.call
    end

    def seed_role_permissions
      SeedData::RolePermissionsService.call
    end

    def seed_users
      SeedData::UsersService.call
    end
  end
end
