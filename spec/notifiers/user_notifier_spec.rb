require 'rails_helper'

RSpec.describe UserNotifier, type: :notifier do
  describe 'inheritance' do
    it 'inherits from ApplicationNotifier' do
      expect(described_class).to be < ApplicationNotifier
    end
  end

  describe '.welcome_back' do
    let(:user) { create(:user) }

    it 'creates notification with correct parameters' do
      expect(described_class).to receive(:with).with(
        record: user,
        message: "Welcome back, #{user.email}! 👋"
      ).and_return(double(deliver_later: true))

      described_class.welcome_back(user)
    end
  end

  describe 'required params' do
    it 'requires message parameter' do
      expect(described_class.required_params).to include(:message)
    end
  end
end
