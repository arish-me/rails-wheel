require 'rails_helper'

RSpec.describe LanguagesHelper, type: :helper do
  it 'has LANGUAGE_MAPPING constant' do
    expect(LanguagesHelper::LANGUAGE_MAPPING).to be_a(Hash)
  end

  it 'responds to language_options' do
    expect(helper).to respond_to(:language_options)
  end
end
