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
    it { should belong_to(:company).optional }
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:permissions).through(:role_permissions) }
  end

  describe 'validations' do
    subject { build(:role) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }

    context 'when company is present' do
      let(:company) { create(:company) }
      let(:role1) { create(:role, name: 'Admin', company: company) }
      let(:role2) { build(:role, name: 'Admin', company: company) }

      it 'validates uniqueness within the same company' do
        role1
        expect(role2).not_to be_valid
        expect(role2.errors[:name]).to include('already exists for this company')
      end
    end

    context 'when company is nil' do
      let(:role1) { create(:role, name: 'Admin', company: nil) }
      let(:role2) { build(:role, name: 'Admin', company: nil) }

      it 'validates uniqueness when both have nil company' do
        role1
        expect(role2).not_to be_valid
        expect(role2.errors[:name]).to include('already exists for this company')
      end
    end

    context 'when companies are different' do
      let(:company1) { create(:company) }
      let(:company2) { create(:company) }
      let(:role1) { create(:role, name: 'Admin', company: company1) }
      let(:role2) { build(:role, name: 'Admin', company: company2) }

      it 'allows same name across different companies' do
        role1
        expect(role2).to be_valid
      end
    end

    context 'when name case is different' do
      let(:company) { create(:company) }
      let(:role1) { create(:role, name: 'Admin', company: company) }
      let(:role2) { build(:role, name: 'admin', company: company) }

      it 'validates uniqueness case-insensitively' do
        role1
        expect(role2).not_to be_valid
        expect(role2.errors[:name]).to include('already exists for this company')
      end
    end
  end

  describe 'scopes' do
    let!(:company) { create(:company) }
    let!(:default_role) { create(:default_role, company: company) }
    let!(:admin_role) { create(:admin_role, company: company) }
    let!(:super_admin_role) { create(:super_admin_role, company: company) }

    describe '.fetch_default_role' do
      it 'returns the default role' do
        expect(Role.fetch_default_role).to eq(default_role)
      end

      context 'when no default role exists' do
        before { Role.update_all(is_default: false) }

        it 'returns nil' do
          expect(Role.fetch_default_role).to be_nil
        end
      end
    end

    describe '.excluding_super_admin' do
      it 'excludes SuperAdmin roles' do
        expect(Role.excluding_super_admin).to include(default_role, admin_role)
        expect(Role.excluding_super_admin).not_to include(super_admin_role)
      end
    end

    describe 'default scope' do
      it 'orders by id descending' do
        expect(Role.all.to_sql).to include('ORDER BY "roles"."id" DESC')
      end
    end
  end

  describe 'search functionality' do
    let!(:company) { create(:company) }
    let!(:admin_role) { create(:role, name: 'Administrator', company: company) }
    let!(:manager_role) { create(:role, name: 'Manager', company: company) }
    let!(:editor_role) { create(:role, name: 'Editor', company: company) }

    describe '.search_by_name' do
      it 'searches by name prefix' do
        results = Role.search_by_name('Admin')
        expect(results).to include(admin_role)
        expect(results).not_to include(manager_role, editor_role)
      end

      it 'returns partial matches' do
        results = Role.search_by_name('Admin')
        expect(results).to include(admin_role) # "Admin" matches "Administrator"
      end

      it 'is case insensitive' do
        results = Role.search_by_name('admin')
        expect(results).to include(admin_role)
      end
    end
  end

  describe 'callbacks' do
    describe '#ensure_single_default' do
      let!(:company) { create(:company) }
      let!(:existing_default) { create(:default_role, company: company) }
      let!(:other_role) { create(:role, company: company) }

      context 'when setting a role as default' do
        it 'unsets other default roles' do
          other_role.update!(is_default: true)
          
          existing_default.reload
          other_role.reload
          
          expect(existing_default.is_default).to be false
          expect(other_role.is_default).to be true
        end
      end

      context 'when updating a role that is already default' do
        it 'does not trigger the callback' do
          expect(existing_default).not_to receive(:ensure_single_default)
          existing_default.update!(name: 'Updated Name')
        end
      end

      context 'when setting is_default to false' do
        it 'does not trigger the callback' do
          expect(existing_default).not_to receive(:ensure_single_default)
          existing_default.update!(is_default: false)
        end
      end

      context 'when creating a new default role' do
        it 'unsets existing default roles' do
          new_default = create(:role, name: 'New Default', is_default: true, company: company)
          
          existing_default.reload
          new_default.reload
          
          expect(existing_default.is_default).to be false
          expect(new_default.is_default).to be true
        end
      end
    end
  end

  describe 'acts_as_tenant' do
    it 'includes acts_as_tenant for company' do
      expect(Role.ancestors).to include(ActsAsTenant::ModelExtensions)
    end
  end

  describe 'instance methods' do
    let(:company) { create(:company) }
    let(:role) { create(:role, company: company) }

    describe '#ensure_single_default' do
      let!(:existing_default) { create(:default_role, company: company) }

      it 'sets other roles is_default to false' do
        role.send(:ensure_single_default)
        
        existing_default.reload
        expect(existing_default.is_default).to be false
      end

      it 'does not affect roles with different company' do
        other_company = create(:company)
        other_default = create(:default_role, company: other_company)
        
        role.send(:ensure_single_default)
        
        other_default.reload
        expect(other_default.is_default).to be true
      end
    end
  end

  describe 'database constraints' do
    it 'has a default value of false for is_default' do
      role = Role.new
      expect(role.is_default).to be false
    end

    it 'allows is_default to be set to true' do
      role = create(:role, is_default: true)
      expect(role.is_default).to be true
    end
  end

  describe 'integration with user_roles' do
    let(:company) { create(:company) }
    let(:role) { create(:role, company: company) }
    let(:user) { create(:user, company: company) }

    it 'can be assigned to users' do
      user_role = create(:user_role, user: user, role: role)
      expect(user.roles).to include(role)
      expect(role.users).to include(user)
    end

    it 'is destroyed when company is destroyed' do
      role
      expect { company.destroy }.to change { Role.count }.by(-1)
    end
  end

  describe 'integration with role_permissions' do
    let(:company) { create(:company) }
    let(:role) { create(:role, company: company) }
    let(:permission) { create(:permission) }

    it 'can have permissions assigned' do
      role_permission = create(:role_permission, role: role, permission: permission)
      expect(role.permissions).to include(permission)
      expect(permission.roles).to include(role)
    end

    it 'destroys associated role_permissions when destroyed' do
      role_permission = create(:role_permission, role: role, permission: permission)
      expect { role.destroy }.to change { RolePermission.count }.by(-1)
    end
  end

  describe 'edge cases' do
    context 'when role name contains special characters' do
      it 'validates correctly' do
        role = build(:role, name: 'Admin & Manager')
        expect(role).to be_valid
      end
    end

    context 'when role name is very long' do
      it 'validates correctly' do
        long_name = 'A' * 255
        role = build(:role, name: long_name)
        expect(role).to be_valid
      end
    end

    context 'when role name is empty string' do
      it 'is invalid' do
        role = build(:role, name: '')
        expect(role).not_to be_valid
        expect(role.errors[:name]).to include("can't be blank")
      end
    end

    context 'when role name is nil' do
      it 'is invalid' do
        role = build(:role, name: nil)
        expect(role).not_to be_valid
        expect(role.errors[:name]).to include("can't be blank")
      end
    end
  end

  describe 'performance considerations' do
    it 'uses database indexes for company_id' do
      expect(Role.connection.indexes('roles').map(&:columns).flatten).to include('company_id')
    end

    it 'uses database indexes for name uniqueness' do
      # The uniqueness validation should be backed by a database index
      expect(Role.connection.indexes('roles').any? { |index| index.columns.include?('name') }).to be true
    end
  end
end
