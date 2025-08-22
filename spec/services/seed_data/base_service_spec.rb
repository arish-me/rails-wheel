require 'rails_helper'

RSpec.describe SeedData::BaseService do
  it 'can be instantiated' do
    expect { described_class.new }.not_to raise_error
  end

  it 'responds to call method' do
    service = described_class
    expect(service).to respond_to(:call)
  end
end
