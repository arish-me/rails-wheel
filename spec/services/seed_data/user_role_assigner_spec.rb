require 'rails_helper'

RSpec.describe SeedData::UserRoleAssigner do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  it 'can be instantiated' do
    expect { SeedData::UserRoleAssigner.new(user, company) }.not_to raise_error
  end

  it 'responds to call method' do
    service = SeedData::UserRoleAssigner.new(user, company)
    expect(service).to respond_to(:call)
  end
end 