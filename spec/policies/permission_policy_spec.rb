require 'rails_helper'

RSpec.describe PermissionPolicy do
  let(:user) { create(:user) }
  let(:record) { create(:permission) }
  let(:policy) { described_class.new(user, record) }

  it 'inherits from ApplicationPolicy' do
    expect(PermissionPolicy).to be < ApplicationPolicy
  end

  it 'can be instantiated' do
    expect { described_class.new(user, record) }.not_to raise_error
  end
end 