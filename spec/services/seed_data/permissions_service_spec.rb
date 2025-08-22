require 'rails_helper'

RSpec.describe SeedData::PermissionsService do
  it 'responds to call method' do
    expect(described_class).to respond_to(:call)
  end
end
