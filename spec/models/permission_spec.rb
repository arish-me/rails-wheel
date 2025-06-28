require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:permission)).to be_valid
    end

    it 'has a valid view permission factory' do
      expect(build(:view_permission)).to be_valid
    end

    it 'has a valid edit permission factory' do
      expect(build(:edit_permission)).to be_valid
    end

    it 'has a valid create permission factory' do
      expect(build(:create_permission)).to be_valid
    end

    it 'has a valid delete permission factory' do
      expect(build(:delete_permission)).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:roles).through(:role_permissions) }
  end

  describe 'validations' do
    subject { build(:permission) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:resource) }
  end

  describe 'factory traits' do
    it 'generates unique names' do
      permission1 = create(:permission)
      permission2 = create(:permission)
      
      expect(permission1.name).not_to eq(permission2.name)
    end

    it 'generates unique resources' do
      permission1 = create(:permission)
      permission2 = create(:permission)
      
      expect(permission1.resource).not_to eq(permission2.resource)
    end
  end

  describe 'specific permission factories' do
    it 'creates view permission with correct name' do
      permission = create(:view_permission)
      expect(permission.name).to eq('view')
    end

    it 'creates edit permission with correct name' do
      permission = create(:edit_permission)
      expect(permission.name).to eq('edit')
    end

    it 'creates create permission with correct name' do
      permission = create(:create_permission)
      expect(permission.name).to eq('create')
    end

    it 'creates delete permission with correct name' do
      permission = create(:delete_permission)
      expect(permission.name).to eq('delete')
    end
  end

  describe 'integration with roles' do
    let(:permission) { create(:permission) }
    let(:role) { create(:role) }

    it 'can be assigned to roles' do
      role_permission = create(:role_permission, role: role, permission: permission)
      expect(role.permissions).to include(permission)
      expect(permission.roles).to include(role)
    end

    it 'destroys associated role_permissions when destroyed' do
      role_permission = create(:role_permission, role: role, permission: permission)
      # Its changing by -2 because view/edit both permissions are created for the same permission
      expect { permission.destroy }.to change { RolePermission.count }.by(-2)
    end
  end
end 