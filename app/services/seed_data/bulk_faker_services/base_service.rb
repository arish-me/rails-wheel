# frozen_string_literal: true

module SeedData
  module BulkFakerServices
    class BaseService
      attr_reader :count

      def initialize(count = 50)
        @count = count
      end

      def self.call(*args, &block)
        new(*args, &block).call
      end

      def log(message)
        puts message
      end

      def benchmark_operation(operation_name)
        log "Starting #{operation_name}..."
        start_time = Time.now
        yield if block_given?
        end_time = Time.now
        duration = (end_time - start_time).round(2)
        log "Completed #{operation_name} in #{duration} seconds"
      end
    end
  end
end
