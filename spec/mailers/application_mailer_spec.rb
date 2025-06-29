require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  it 'inherits from ActionMailer::Base' do
    expect(ApplicationMailer).to be < ActionMailer::Base
  end

  it 'sets default from email' do
    expect(ApplicationMailer.default[:from]).to eq(ENV.fetch("NO_REPLY_EMAIL") { "noreply@wheel.com" })
  end

  it 'can be instantiated' do
    expect { ApplicationMailer.new }.not_to raise_error
  end
end
