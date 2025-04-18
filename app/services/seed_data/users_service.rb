# frozen_string_literal: true

module SeedData
  class UsersService < BaseService
    USERS = [
      { email: "superadmin@wheel.com", role: "SuperAdmin", first_name: "Super", last_name: "Admin", gender: 1 },
      { email: "admin@wheel.com", role: "Admin", first_name: "Admin", last_name: "User", gender: 1 },
      { email: "user@wheel.com", role: "User", first_name: "Regular", last_name: "User", gender: 1 },
      { email: "recruiter@wheel.com", role: "Recruiter", first_name: "Recruiter", last_name: "User", gender: 1 },
      { email: "guest@wheel.com", role: "Guest", first_name: "Guest", last_name: "User", gender: 1 }
    ].freeze

    def call
      create_users_with_roles
    end

    private

    def create_users_with_roles
      log "Creating Users and Assigning Roles..."

      USERS.each do |user_data|
        user = User.find_or_initialize_by(email: user_data[:email]) do |u|
          u.password = "#{user_data[:email]}"
          u.password_confirmation = "#{user_data[:email]}"
          u.confirmed_at = Time.now.utc
        end

        user.save(validate: false)
        user.skip_confirmation!

        role = Role.find_by(name: user_data[:role])
        UserRole.find_or_create_by!(user: user, role: role)

        profile = user.profile || user.build_profile
        profile.assign_attributes(
          first_name: user_data[:first_name],
          last_name: user_data[:last_name],
          gender: user_data[:gender]
        )
        profile.save!
      end

      log "Users created and assigned roles."
    end
  end
end
