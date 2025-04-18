# frozen_string_literal: true

module SeedData
  class BaseService
    def self.call(*args, &block)
      new(*args, &block).call
    end

    def log(message)
      puts message
    end
  end
end
