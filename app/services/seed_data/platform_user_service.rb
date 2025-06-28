module SeedData
  class PlatformUserService
    def initialize(email)
      @email = email
    end
    def call
      seed_platform_user
    end

    def seed_platform_user
      service_user = User.find_or_initialize_by(email: @email) do |u|
        u.password = @email
        u.password_confirmation = @email
        u.user_type = 99
        u.onboarded_at = Time.now.utc
        u.skip_confirmation = true
      end
      service_user.confirm
    end
  end
end
