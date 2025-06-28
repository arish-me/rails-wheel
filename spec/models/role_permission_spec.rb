require 'rails_helper'

RSpec.describe RolePermission, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:role_permission)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:role) }
    it { should belong_to(:permission) }
  end

  describe 'enums' do
    it { should define_enum_for(:action).with_values({ view: 0, edit: 1 }) }
  end

  describe 'validations' do
    subject { build(:role_permission) }

    describe 'permission_id uniqueness' do
      let(:company) { create(:company) }
      let(:role) { create(:role, company: company) }
      let(:permission) { create(:permission) }

      before do
        create(:role_permission, role: role, permission: permission, company: company)
      end

      it 'validates uniqueness of permission_id scoped to role_id' do
        duplicate = build(:role_permission, role: role, permission: permission, company: company)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:permission_id]).to include('already assigned to this role')
      end
    end
  end

  describe 'acts_as_tenant' do
    it 'includes acts_as_tenant for company' do
      expect(RolePermission.ancestors).to include(ActsAsTenant::ModelExtensions)
    end
  end

  describe 'uniqueness validation' do
    let(:company) { create(:company) }
    let(:role) { create(:role, company: company) }
    let(:permission) { create(:permission) }

    it 'prevents duplicate permission assignments to the same role' do
      create(:role_permission, role: role, permission: permission, company: company)
      duplicate = build(:role_permission, role: role, permission: permission, company: company)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:permission_id]).to include('already assigned to this role')
    end

    it 'allows same permission for different roles' do
      role2 = create(:role, company: company)
      create(:role_permission, role: role, permission: permission, company: company)
      role_permission2 = build(:role_permission, role: role2, permission: permission, company: company)
      
      expect(role_permission2).to be_valid
    end
  end

  describe 'enum values' do
    it 'has correct action values' do
      expect(RolePermission.actions).to eq({ 'view' => 0, 'edit' => 1 })
    end

    it 'can be set to view' do
      role_permission = create(:role_permission, action: :view)
      expect(role_permission.view?).to be true
    end

    it 'can be set to edit' do
      role_permission = create(:role_permission, action: :edit)
      expect(role_permission.edit?).to be true
    end
  end
end 