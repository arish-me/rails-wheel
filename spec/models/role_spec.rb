require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:role)).to be_valid
    end

    it 'has a valid default role factory' do
      expect(build(:default_role)).to be_valid
    end

    it 'has a valid admin role factory' do
      expect(build(:admin_role)).to be_valid
    end

    it 'has a valid super admin role factory' do
      expect(build(:super_admin_role)).to be_valid
    end

    it 'has a valid role with permissions factory' do
      expect(build(:role_with_permissions)).to be_valid
    end

    it 'has a valid role with users factory' do
      expect(build(:role_with_users)).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:users).through(:user_roles) }
    it { should belong_to(:company) }
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:permissions).through(:role_permissions) }
  end
end
