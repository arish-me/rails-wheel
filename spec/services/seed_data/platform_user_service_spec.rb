require 'rails_helper'

RSpec.describe SeedData::PlatformUserService do
  it 'can be instantiated' do
    expect { SeedData::PlatformUserService.new(email: 'admin@wheel.com') }.not_to raise_error
  end

  it 'responds to call method' do
    service = SeedData::PlatformUserService.new(email: 'admin@wheel.com')
    expect(service).to respond_to(:call)
  end
end
