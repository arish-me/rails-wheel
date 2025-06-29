require 'rails_helper'

RSpec.describe SeedData::RolesService do
  it 'responds to call method' do
    expect(SeedData::RolesService).to respond_to(:call)
  end
end
