require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }
  let(:test_env) { instance_double(env) }

  before do
    allow_any_instance_of(described_class).to receive(:env).and_return(test_env)
  end

  context 'with a verified user' do
    let(:test_warden) { instance_double(warden, user:) }

    before do
      allow(test_env).to receive(:[]).with('warden').and_return(test_warden)
    end

    it 'successfully connects' do
      connect '/cable'

      expect(connection.current_user).to eq user
    end
  end

  context 'without a verified user' do
    let(:test_warden) { instance_double(warden, user: nil) }

    before do
      allow(test_env).to receive(:[]).with('warden').and_return(test_warden)
    end

    it 'rejects connection' do
      expect { connect '/cable' }.to have_rejected_connection
    end
  end
end
