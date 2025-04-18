# frozen_string_literal: true

module SeedData
  module BulkFakerServices
    class UsersService < BaseService
      def call
        benchmark_operation("Bulk User Creation") do
          create_users_with_roles
        end
      end

      private

      def create_users_with_roles
        log "Creating #{count} random users..."

        # Pre-fetch all roles to avoid N+1 queries
        roles = Role.all.to_a
        default_role = roles.find { |r| r.is_default } || roles.first

        # Batch creation for better performance
        created_count = 0
        failed_count = 0

        # Use batch insertion for better performance
        users_to_create = []
        user_roles_to_create = []
        profiles_to_create = []

        count.times do |i|
          email = unique_email

          # Skip if email already exists
          if User.exists?(email: email)
            failed_count += 1
            next
          end

          # Create user with its associations
          now = Time.current

          # Prepare user data
          users_to_create << {
            email: email,
            encrypted_password: Devise::Encryptor.digest(User, "password123"),
            confirmed_at: now,
            created_at: now,
            updated_at: now
          }
        end

        # Bulk insert users
        if users_to_create.any?
          User.insert_all(users_to_create)
          created_count = users_to_create.size

          # Now fetch the created users to create their associations
          bulk_users = User.where(email: users_to_create.map { |u| u[:email] })

          # Prepare profile and role data
          bulk_users.each_with_index do |user, index|
            # Profile data
            profiles_to_create << {
              user_id: user.id,
              first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              gender: rand(1..3),
              created_at: user.created_at,
              updated_at: user.updated_at
            }

            # UserRole data - use index for role selection logic
            role = index % 10 == 0 ? roles.sample : default_role
            user_roles_to_create << {
              user_id: user.id,
              role_id: role.id,
              created_at: user.created_at,
              updated_at: user.updated_at
            }
          end

          # Bulk insert profiles and user roles
          Profile.insert_all(profiles_to_create) if profiles_to_create.any?
          UserRole.insert_all(user_roles_to_create) if user_roles_to_create.any?
        end

        log "Created #{created_count} users (#{failed_count} skipped due to duplicates)"
      end

      def unique_email
        # Generate unique email using a combination of values to minimize duplicates
        domain = [ "example.com", "test.org", "faker.net", "dummy.io", "sample.dev" ].sample
        prefix = [
          Faker::Internet.username(specifier: 5..12),
          Faker::Internet.user_name(specifier: 5..12),
          "user_#{SecureRandom.hex(4)}"
        ].sample

        "#{prefix}@#{domain}"
      end
    end
  end
end
