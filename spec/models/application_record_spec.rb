require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe 'inheritance' do
    it 'inherits from ActiveRecord::Base' do
      expect(ApplicationRecord).to be < ActiveRecord::Base
    end
  end

  describe 'modules' do
    it 'includes PgSearch::Model' do
      expect(ApplicationRecord.included_modules).to include(PgSearch::Model)
    end
  end
end 