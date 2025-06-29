require 'rails_helper'

RSpec.describe SeedData::BulkFakerServices::UsersService, type: :service do
  let(:service) { described_class.new(5) }

  describe '#call' do
    it 'calls benchmark_operation with bulk user creation' do
      expect(service).to receive(:benchmark_operation).with("Bulk User Creation")
      service.call
    end
  end

  describe '#unique_email' do
    it 'generates an email with valid format' do
      email = service.send(:unique_email)
      expect(email).to match(/^[^@]+@[^@]+$/)
    end

    it 'generates different emails on multiple calls' do
      email1 = service.send(:unique_email)
      email2 = service.send(:unique_email)
      expect(email1).not_to eq(email2)
    end
  end

  describe 'inheritance' do
    it 'inherits from BaseService' do
      expect(described_class).to be < SeedData::BulkFakerServices::BaseService
    end
  end
end
