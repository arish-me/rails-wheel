require 'rails_helper'

RSpec.describe ApplicationCable::Channel, type: :channel do
  it 'inherits from ActionCable::Channel::Base' do
    expect(ApplicationCable::Channel).to be < ActionCable::Channel::Base
  end

  it 'can be instantiated with proper arguments' do
    connection = double('connection', identifiers: [ :current_user ])
    identifier = 'test_channel'

    expect { ApplicationCable::Channel.new(connection, identifier) }.not_to raise_error
  end

  it 'can be instantiated with connection, identifier, and params' do
    connection = double('connection', identifiers: [ :current_user ])
    identifier = 'test_channel'
    params = { room: 'test_room' }

    expect { ApplicationCable::Channel.new(connection, identifier, params) }.not_to raise_error
  end

  describe 'instance methods' do
    let(:connection) { double('connection', identifiers: [ :current_user ]) }
    let(:identifier) { 'test_channel' }
    let(:channel) { ApplicationCable::Channel.new(connection, identifier) }

    it 'has access to connection' do
      expect(channel.connection).to eq(connection)
    end

    it 'has access to identifier' do
      expect(channel.identifier).to eq(identifier)
    end

    it 'can access identifiers from connection' do
      expect(channel.connection.identifiers).to eq([ :current_user ])
    end
  end

  describe 'channel behavior' do
    let(:connection) { double('connection', identifiers: [ :current_user ]) }
    let(:identifier) { 'test_channel' }
    let(:channel) { ApplicationCable::Channel.new(connection, identifier) }

    it 'can be used as a base class for other channels' do
      expect(ApplicationCable::Channel).to be < ActionCable::Channel::Base
    end
  end

  describe 'inheritance chain' do
    it 'inherits from ActionCable::Channel::Base' do
      expect(ApplicationCable::Channel.ancestors).to include(ActionCable::Channel::Base)
    end

    it 'is a subclass of ActionCable::Channel::Base' do
      expect(ApplicationCable::Channel).to be < ActionCable::Channel::Base
    end

    it 'can be used as a parent class' do
      expect { Class.new(ApplicationCable::Channel) }.not_to raise_error
    end
  end

  describe 'instantiation edge cases' do
    context 'with minimal connection' do
      it 'requires at least identifiers method' do
        connection = double('connection', identifiers: [])
        expect { ApplicationCable::Channel.new(connection, 'test') }.not_to raise_error
      end
    end

    context 'with different identifier types' do
      it 'accepts string identifiers' do
        connection = double('connection', identifiers: [ :current_user ])
        expect { ApplicationCable::Channel.new(connection, 'string_id') }.not_to raise_error
      end

      it 'accepts symbol identifiers' do
        connection = double('connection', identifiers: [ :current_user ])
        expect { ApplicationCable::Channel.new(connection, :symbol_id) }.not_to raise_error
      end
    end

    context 'with different parameter types' do
      it 'accepts hash parameters' do
        connection = double('connection', identifiers: [ :current_user ])
        params = { key: 'value', number: 123 }
        expect { ApplicationCable::Channel.new(connection, 'test', params) }.not_to raise_error
      end

      it 'accepts empty hash parameters' do
        connection = double('connection', identifiers: [ :current_user ])
        params = {}
        expect { ApplicationCable::Channel.new(connection, 'test', params) }.not_to raise_error
      end
    end
  end

  describe 'channel capabilities' do
    let(:connection) { double('connection', identifiers: [ :current_user ]) }
    let(:channel) { ApplicationCable::Channel.new(connection, 'test') }

    it 'can stream to specific targets' do
      allow(channel).to receive(:stream_for)
      expect(channel).to respond_to(:stream_for)
    end

    it 'can stream from specific sources' do
      allow(channel).to receive(:stream_from)
      expect(channel).to respond_to(:stream_from)
    end

    it 'can stop all streams' do
      allow(channel).to receive(:stop_all_streams)
      expect(channel).to respond_to(:stop_all_streams)
    end
  end

  describe 'integration with Rails' do
    it 'is properly namespaced under ApplicationCable' do
      expect(ApplicationCable::Channel.name).to eq('ApplicationCable::Channel')
    end

    it 'can be autoloaded by Rails' do
      expect { ApplicationCable::Channel }.not_to raise_error
    end
  end
end
