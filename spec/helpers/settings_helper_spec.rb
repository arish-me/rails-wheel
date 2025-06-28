require 'rails_helper'

RSpec.describe SettingsHelper, type: :helper do
  it 'has SETTINGS_ORDER constant' do
    expect(SettingsHelper::SETTINGS_ORDER).to be_a(Array)
  end

  it 'responds to adjacent_setting' do
    expect(helper).to respond_to(:adjacent_setting)
  end
end 