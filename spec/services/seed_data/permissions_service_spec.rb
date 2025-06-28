require 'rails_helper'

RSpec.describe SeedData::PermissionsService do
  it 'responds to call method' do
    expect(SeedData::PermissionsService).to respond_to(:call)
  end
end 