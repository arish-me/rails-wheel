module SeedData
  class PlatformUserService < BaseService
    def initialize(email)
      @email = email
    end
    def call
      seed_platform_user
    end

    def seed_platform_user
      log "Creating Plafrom user with email #{@email}"
      user = User.find_or_initialize_by(email: @email) do |u|
        u.password = @email
        u.password_confirmation = @email
        u.user_type = 99
        u.onboarded_at = Time.now.utc
      end
      user.skip_confirmation!
      log "Finish Creating Plafrom user with email #{@email}"
    end
  end
end
