require 'rails_helper'

RSpec.describe SeedData::BulkFakerServices::BaseService, type: :service do
  let(:service) { described_class.new(100) }

  describe '#initialize' do
    it 'sets the count attribute' do
      expect(service.count).to eq(100)
    end

    it 'uses default count when not provided' do
      service = described_class.new
      expect(service.count).to eq(50)
    end
  end

  describe '#log' do
    it 'outputs the message' do
      expect { service.log("test message") }.to output("test message\n").to_stdout
    end
  end

  describe '#benchmark_operation' do
    it 'logs start and completion messages' do
      expect { service.benchmark_operation("Test Operation") { "result" } }.to output(/Starting Test Operation/).to_stdout
    end

    it 'yields the block' do
      result = nil
      service.benchmark_operation("Test") { result = "success" }
      expect(result).to eq("success")
    end
  end
end
