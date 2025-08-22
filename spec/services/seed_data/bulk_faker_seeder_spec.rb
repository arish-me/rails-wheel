require 'rails_helper'

RSpec.describe SeedData::BulkFakerSeeder do
  it 'can be instantiated' do
    expect { described_class.new(10) }.not_to raise_error
  end

  it 'responds to call method' do
    seeder = described_class.new(10)
    expect(seeder).to respond_to(:call)
  end
end
