require 'rails_helper'

RSpec.describe SeedData::MainSeeder do
  it 'inherits from BaseService' do
    expect(described_class).to be < SeedData::BaseService
  end

  it 'can be instantiated' do
    expect { described_class.new }.not_to raise_error
  end

  it 'responds to call method' do
    seeder = described_class.new
    expect(seeder).to respond_to(:call)
  end

  it 'has faker_count attribute' do
    seeder = described_class.new(50)
    expect(seeder.faker_count).to eq(50)
  end
end
