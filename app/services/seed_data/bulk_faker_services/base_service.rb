# frozen_string_literal: true

module SeedData
  module BulkFakerServices
    class BaseService
      attr_reader :count

      def initialize(count = 50)
        @count = count
      end

      def self.call(*, &)
        new(*, &).call
      end

      def log(message)
        Rails.logger.debug message
      end

      def benchmark_operation(operation_name)
        log "Starting #{operation_name}..."
        start_time = Time.zone.now
        yield if block_given?
        end_time = Time.zone.now
        duration = (end_time - start_time).round(2)
        log "Completed #{operation_name} in #{duration} seconds"
      end
    end
  end
end
