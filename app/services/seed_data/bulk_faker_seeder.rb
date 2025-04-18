# frozen_string_literal: true

module SeedData
  class BulkFakerSeeder < BaseService
    attr_reader :count

    def initialize(count = 50)
      @count = count
    end

    def call
      log "Starting bulk faker seeding process..."
      seed_users
      seed_categories
      log "Bulk seeding completed successfully!"
    end

    private

    def seed_users
      BulkFakerServices::UsersService.new(count).call
    end

    def seed_categories
      BulkFakerServices::CategoriesService.new(count).call
    end
  end
end
