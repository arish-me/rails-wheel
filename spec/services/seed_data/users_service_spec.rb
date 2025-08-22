require 'rails_helper'

RSpec.describe SeedData::UsersService do
  let(:company) { create(:company) }

  it 'can be instantiated' do
    expect { described_class.new(company) }.not_to raise_error
  end

  it 'responds to call method' do
    service = described_class.new(company)
    expect(service).to respond_to(:call)
  end
end
