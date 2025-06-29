require 'rails_helper'

RSpec.describe ApplicationPolicy do
  let(:user) { create(:user) }
  let(:record) { double('record') }
  let(:policy) { described_class.new(user, record) }

  it 'can be instantiated' do
    expect { described_class.new(user, record) }.not_to raise_error
  end

  it 'has user and record attributes' do
    expect(policy.user).to eq(user)
    expect(policy.record).to eq(record)
  end

  it 'responds to can_view?' do
    expect(policy).to respond_to(:can_view?)
  end

  it 'responds to can_edit?' do
    expect(policy).to respond_to(:can_edit?)
  end

  describe 'Scope' do
    let(:scope) { described_class::Scope.new(user, User) }

    it 'can be instantiated' do
      expect { described_class::Scope.new(user, User) }.not_to raise_error
    end

    it 'raises error when resolve is called' do
      expect { scope.resolve }.to raise_error(NoMethodError)
    end
  end
end
