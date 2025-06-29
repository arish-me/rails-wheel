FactoryBot.define do
  factory :channel_connection, class: 'ActionCable::Connection::Base' do
    transient do
      user { create(:user) }
    end

    initialize_with do
      connection = double('connection')
      allow(connection).to receive(:current_user).and_return(user)
      connection
    end
  end
end
