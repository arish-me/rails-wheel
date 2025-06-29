require 'rails_helper'

RSpec.describe SeedData::RolePermissionsService do
  it 'responds to call method' do
    expect(SeedData::RolePermissionsService).to respond_to(:call)
  end
end
