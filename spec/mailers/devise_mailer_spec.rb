require 'rails_helper'

RSpec.describe DeviseMailer, type: :mailer do
  it 'inherits from Devise::Mailer' do
    expect(described_class).to be < Devise::Mailer
  end

  it 'sets default from email' do
    expect(described_class.default[:from]).to eq(ENV.fetch('NO_REPLY_EMAIL') { 'noreply@wheel.com' })
  end

  it 'can send confirmation instructions' do
    user = create(:user)
    expect { described_class.confirmation_instructions(user, 'token') }.not_to raise_error
  end

  describe 'inheritance' do
    it 'inherits from Devise::Mailer' do
      expect(described_class).to be < Devise::Mailer
    end

    it 'inherits from ActionMailer::Base through Devise::Mailer' do
      expect(described_class.ancestors).to include(ActionMailer::Base)
    end
  end

  describe 'default configuration' do
    it 'sets default from email' do
      expect(described_class.default[:from]).to eq(ENV.fetch('NO_REPLY_EMAIL') { 'noreply@wheel.com' })
    end

    it 'sets layout to mailer' do
      expect(described_class._layout).to eq('mailer')
    end
  end

  describe 'environment variable handling' do
    context 'when NO_REPLY_EMAIL is set' do
      before do
        @original_env = ENV.fetch('NO_REPLY_EMAIL', nil)
        ENV['NO_REPLY_EMAIL'] = 'devise@example.com'
        # Reload the class to pick up the new environment variable
        load 'app/mailers/devise_mailer.rb'
      end

      after do
        ENV['NO_REPLY_EMAIL'] = @original_env
        # Reload the class to restore original state
        load 'app/mailers/devise_mailer.rb'
      end

      it 'uses the environment variable' do
        expect(described_class.default[:from]).to eq('devise@example.com')
      end
    end

    context 'when NO_REPLY_EMAIL is not set' do
      before do
        @original_env = ENV.fetch('NO_REPLY_EMAIL', nil)
        ENV.delete('NO_REPLY_EMAIL')
        # Reload the class to pick up the new environment variable
        load 'app/mailers/devise_mailer.rb'
      end

      after do
        ENV['NO_REPLY_EMAIL'] = @original_env
        # Reload the class to restore original state
        load 'app/mailers/devise_mailer.rb'
      end

      it 'uses the default fallback email' do
        expect(described_class.default[:from]).to eq('noreply@wheel.com')
      end
    end
  end

  describe 'devise integration' do
    it 'includes devise mailer functionality' do
      expect(described_class.ancestors).to include(Devise::Mailer)
    end

    it 'can be used for devise emails' do
      expect(described_class.respond_to?(:confirmation_instructions)).to be true
    end
  end

  describe 'mailer functionality' do
    it 'can be instantiated' do
      expect { described_class.new }.not_to raise_error
    end

    it 'can be used as a base class for other devise mailers' do
      expect { Class.new(described_class) }.not_to raise_error
    end
  end

  describe 'devise email methods' do
    let(:user) { create(:user) }

    it 'can send confirmation instructions' do
      expect { described_class.confirmation_instructions(user, 'token') }.not_to raise_error
    end

    it 'can send reset password instructions' do
      expect { described_class.reset_password_instructions(user, 'token') }.not_to raise_error
    end

    it 'can send unlock instructions' do
      expect { described_class.unlock_instructions(user, 'token') }.not_to raise_error
    end

    it 'can send email changed notification' do
      expect { described_class.email_changed(user) }.not_to raise_error
    end

    it 'can send password change notification' do
      expect { described_class.password_change(user) }.not_to raise_error
    end
  end
end
