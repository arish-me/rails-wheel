require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  it "has a valid factory" do
    expect(user).to be_valid
  end

  it "is invalid without an email" do
    user.email = nil
  end
end
