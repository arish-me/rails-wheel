module ChannelHelper
  def create_channel_connection(user)
    connection = double('connection')
    allow(connection).to receive(:current_user).and_return(user)
    connection
  end

  def create_channel(channel_class, user = nil, identifier = 'test_channel')
    user ||= create(:user)
    connection = create_channel_connection(user)
    channel_class.new(connection, identifier)
  end

  def create_channel_with_params(channel_class, user = nil, identifier = 'test_channel', params = {})
    user ||= create(:user)
    connection = create_channel_connection(user)
    channel_class.new(connection, identifier, params)
  end
end

RSpec.configure do |config|
  config.include ChannelHelper, type: :channel
end
