require 'rails_helper'

RSpec.describe SeedData::BaseService do
  it 'can be instantiated' do
    expect { SeedData::BaseService.new }.not_to raise_error
  end

  it 'responds to call method' do
    service = SeedData::BaseService
    expect(service).to respond_to(:call)
  end
end
