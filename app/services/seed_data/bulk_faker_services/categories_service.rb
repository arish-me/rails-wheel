# frozen_string_literal: true

module SeedData
  module BulkFakerServices
    class CategoriesService < BaseService
      def call
        benchmark_operation("Bulk Category Creation") do
          create_categories
        end
      end

      private

      def create_categories
        log "Creating #{count} random categories..."

        # Pre-fetch users to avoid N+1 queries and distribute categories across them
        users = User.all.to_a
        return if users.empty?

        # Batch creation for better performance
        created_count = 0
        failed_count = 0

        # Track used names to avoid duplicates
        used_names = Set.new(Category.pluck(:name))
        categories_to_create = []

        count.times do
          # Generate a unique category name
          name = unique_category_name(used_names)

          # Skip if we couldn't generate a unique name
          if name.nil?
            failed_count += 1
            next
          end

          used_names.add(name)

          # Randomly assign to a user
          user = users.sample
          now = Time.current

          categories_to_create << {
            name: name,
            description: Faker::Lorem.paragraph(sentence_count: 2, supplemental: true),
            user_id: user.id,
            created_at: now,
            updated_at: now
          }

          # Bulk insert in batches of 100 for better performance
          if categories_to_create.size >= 100
            Category.insert_all(categories_to_create)
            created_count += categories_to_create.size
            categories_to_create = []
          end
        end

        # Insert any remaining categories
        if categories_to_create.any?
          Category.insert_all(categories_to_create)
          created_count += categories_to_create.size
        end

        log "Created #{created_count} categories (#{failed_count} skipped due to duplicates)"
      end

      def unique_category_name(used_names)
        max_attempts = 10
        attempt = 0

        while attempt < max_attempts
          name = generate_category_name
          return name unless used_names.include?(name)
          attempt += 1
        end

        # If we've exhausted attempts, create a truly unique name with timestamp
        "Category_#{Time.now.to_i}_#{SecureRandom.hex(4)}"
      end

      def generate_category_name
        prefixes = [ "Tech", "Home", "Work", "Personal", "Health", "Finance", "Education", "Travel" ]
        categories = [ "Products", "Services", "Projects", "Ideas", "Tasks", "Notes", "Goals", "Events" ]

        [
          "#{prefixes.sample} #{categories.sample}",
          Faker::Commerce.department(max: 2),
          Faker::Hobby.activity,
          Faker::Job.field
        ].sample
      end
    end
  end
end
