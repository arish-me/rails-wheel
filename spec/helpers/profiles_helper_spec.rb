require 'rails_helper'

RSpec.describe ProfilesHelper, type: :helper do
  it 'has COUNTRY_MAPPING constant' do
    expect(ProfilesHelper::COUNTRY_MAPPING).to be_a(Hash)
  end

  it 'responds to display_user_name' do
    expect(helper).to respond_to(:display_user_name)
  end
end 