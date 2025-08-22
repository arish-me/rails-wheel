require 'rails_helper'

RSpec.describe RolePermissionPolicy do
  let(:user) { create(:user) }
  let(:record) { create(:role_permission) }
  let(:policy) { described_class.new(user, record) }

  it 'inherits from ApplicationPolicy' do
    expect(described_class).to be < ApplicationPolicy
  end

  it 'can be instantiated' do
    expect { described_class.new(user, record) }.not_to raise_error
  end
end
