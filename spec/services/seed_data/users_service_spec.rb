require 'rails_helper'

RSpec.describe SeedData::UsersService do
  let(:company) { create(:company) }
  it 'can be instantiated' do
    expect { SeedData::UsersService.new(company) }.not_to raise_error
  end

  it 'responds to call method' do
    service = SeedData::UsersService.new(company)
    expect(service).to respond_to(:call)
  end
end 