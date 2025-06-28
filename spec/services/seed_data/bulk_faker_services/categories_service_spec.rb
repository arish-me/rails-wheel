require 'rails_helper'

RSpec.describe SeedData::BulkFakerServices::CategoriesService, type: :service do
  let(:service) { described_class.new(5) }

  describe '#call' do
    it 'calls benchmark_operation with bulk category creation' do
      expect(service).to receive(:benchmark_operation).with("Bulk Category Creation")
      service.call
    end
  end

  describe '#unique_category_name' do
    let(:used_names) { Set.new(['Existing Category']) }

    it 'returns a name not in used_names' do
      name = service.send(:unique_category_name, used_names)
      expect(used_names).not_to include(name)
    end
  end

  describe '#generate_category_name' do
    it 'returns a string' do
      name = service.send(:generate_category_name)
      expect(name).to be_a(String)
      expect(name).not_to be_empty
    end
  end

  describe 'inheritance' do
    it 'inherits from BaseService' do
      expect(described_class).to be < SeedData::BulkFakerServices::BaseService
    end
  end
end 