require 'rails_helper'

RSpec.describe DeviseMailer, type: :mailer do
  it 'inherits from Devise::Mailer' do
    expect(DeviseMailer).to be < Devise::Mailer
  end

  it 'sets default from email' do
    expect(DeviseMailer.default[:from]).to eq(ENV.fetch("NO_REPLY_EMAIL") { "noreply@wheel.com" })
  end

  it 'can send confirmation instructions' do
    user = create(:user)
    expect { DeviseMailer.confirmation_instructions(user, 'token') }.not_to raise_error
  end

  describe 'inheritance' do
    it 'inherits from Devise::Mailer' do
      expect(DeviseMailer).to be < Devise::Mailer
    end

    it 'inherits from ActionMailer::Base through Devise::Mailer' do
      expect(DeviseMailer.ancestors).to include(ActionMailer::Base)
    end
  end

  describe 'default configuration' do
    it 'sets default from email' do
      expect(DeviseMailer.default[:from]).to eq(ENV.fetch("NO_REPLY_EMAIL") { "noreply@wheel.com" })
    end

    it 'sets layout to mailer' do
      expect(DeviseMailer._layout).to eq('mailer')
    end
  end

  describe 'environment variable handling' do
    context 'when NO_REPLY_EMAIL is set' do
      before do
        @original_env = ENV['NO_REPLY_EMAIL']
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
        expect(DeviseMailer.default[:from]).to eq('devise@example.com')
      end
    end

    context 'when NO_REPLY_EMAIL is not set' do
      before do
        @original_env = ENV['NO_REPLY_EMAIL']
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
        expect(DeviseMailer.default[:from]).to eq('noreply@wheel.com')
      end
    end
  end

  describe 'devise integration' do
    it 'includes devise mailer functionality' do
      expect(DeviseMailer.ancestors).to include(Devise::Mailer)
    end

    it 'can be used for devise emails' do
      expect(DeviseMailer.respond_to?(:confirmation_instructions)).to be true
    end
  end

  describe 'mailer functionality' do
    it 'can be instantiated' do
      expect { DeviseMailer.new }.not_to raise_error
    end

    it 'can be used as a base class for other devise mailers' do
      expect { Class.new(DeviseMailer) }.not_to raise_error
    end
  end

  describe 'devise email methods' do
    let(:user) { create(:user) }

    it 'can send confirmation instructions' do
      expect { DeviseMailer.confirmation_instructions(user, 'token') }.not_to raise_error
    end

    it 'can send reset password instructions' do
      expect { DeviseMailer.reset_password_instructions(user, 'token') }.not_to raise_error
    end

    it 'can send unlock instructions' do
      expect { DeviseMailer.unlock_instructions(user, 'token') }.not_to raise_error
    end

    it 'can send email changed notification' do
      expect { DeviseMailer.email_changed(user) }.not_to raise_error
    end

    it 'can send password change notification' do
      expect { DeviseMailer.password_change(user) }.not_to raise_error
    end
  end
end
