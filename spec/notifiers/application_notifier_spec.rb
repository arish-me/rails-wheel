require 'rails_helper'

RSpec.describe ApplicationNotifier, type: :notifier do
  describe 'inheritance' do
    it 'inherits from Noticed::Event' do
      expect(ApplicationNotifier).to be < Noticed::Event
    end
  end

  it 'can be instantiated' do
    expect { ApplicationNotifier.new }.not_to raise_error
  end
end 