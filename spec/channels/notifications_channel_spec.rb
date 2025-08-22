require 'rails_helper'

RSpec.describe NotificationsChannel, type: :channel do
  let(:user) { create(:user) }
  let(:connection) do
    double('connection',
           current_user: user,
           identifiers: [:current_user],
           logger: Rails.logger,
           transmit: nil,
           reject: nil)
  end
  let(:identifier) { 'notifications' }
  let(:channel) { described_class.new(connection, identifier) }

  before do
    allow(channel).to receive(:stream_for)
    allow(channel).to receive(:stop_all_streams)
    allow(Rails.logger).to receive(:info)
  end

  describe '#subscribed' do
    it 'streams for the current user' do
      expect(channel).to receive(:stream_for).with(user)
      channel.subscribed
    end

    it 'logs the subscription' do
      expect(Rails.logger).to receive(:info).with("User #{user.id} subscribed to notifications")
      channel.subscribed
    end
  end

  describe '#unsubscribed' do
    it 'stops all streams' do
      expect(channel).to receive(:stop_all_streams)
      channel.unsubscribed
    end

    it 'logs the unsubscription' do
      expect(Rails.logger).to receive(:info).with("User #{user.id} unsubscribed from notifications")
      channel.unsubscribed
    end
  end

  describe '#receive' do
    let(:data) { { message: 'test' } }

    it 'logs the received data' do
      expect(Rails.logger).to receive(:info).with("Received data in NotificationsChannel: #{data.inspect}")
      channel.receive(data)
    end
  end

  describe 'inheritance' do
    it 'inherits from ApplicationCable::Channel' do
      expect(described_class).to be < ApplicationCable::Channel
    end
  end

  describe 'instantiation' do
    it 'can be instantiated with connection and identifier' do
      expect { described_class.new(connection, identifier) }.not_to raise_error
    end

    it 'can be instantiated with connection, identifier, and params' do
      params = { room: 'test_room' }
      expect { described_class.new(connection, identifier, params) }.not_to raise_error
    end
  end
end
