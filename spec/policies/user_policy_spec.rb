require 'rails_helper'

RSpec.describe UserPolicy do
  let(:user) { create(:user) }
  let(:record) { create(:user) }
  let(:policy) { described_class.new(user, record) }

  it 'inherits from ApplicationPolicy' do
    expect(UserPolicy).to be < ApplicationPolicy
  end

  it 'can be instantiated' do
    expect { described_class.new(user, record) }.not_to raise_error
  end
end
