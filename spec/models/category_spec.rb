require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:category)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'search functionality' do
    let(:user) { create(:user) }
    let!(:category1) { create(:category, name: 'Technology', user: user) }
    let!(:category2) { create(:category, name: 'Business', user: user) }
    let!(:category3) { create(:category, name: 'Marketing', user: user) }

    it 'searches by name prefix' do
      results = Category.search_by_name('Tech')
      expect(results).to include(category1)
      expect(results).not_to include(category2, category3)
    end
  end
end 