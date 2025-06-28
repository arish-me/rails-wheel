require 'rails_helper'

RSpec.describe SeedData::MainSeeder do
  it 'inherits from BaseService' do
    expect(SeedData::MainSeeder).to be < SeedData::BaseService
  end

  it 'can be instantiated' do
    expect { SeedData::MainSeeder.new }.not_to raise_error
  end

  it 'responds to call method' do
    seeder = SeedData::MainSeeder.new
    expect(seeder).to respond_to(:call)
  end

  it 'has faker_count attribute' do
    seeder = SeedData::MainSeeder.new(50)
    expect(seeder.faker_count).to eq(50)
  end
end 