require 'rails_helper'

RSpec.describe ApplicationDeliveryMethod, type: :notifier do
  describe 'inheritance' do
    it 'inherits from Noticed::DeliveryMethod' do
      expect(described_class).to be < Noticed::DeliveryMethod
    end
  end

  it 'can be instantiated' do
    expect { described_class.new }.not_to raise_error
  end
end
