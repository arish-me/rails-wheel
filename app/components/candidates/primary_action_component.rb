module Candidates
  class PrimaryActionComponent < ViewComponent::Base
    attr_reader :user, :developer, :business

    def initialize(user:, developer:, business:, public_key:)
      @user = user
      @developer = developer
      @business = business
      @public_key = public_key
    end

    def owner?
      user&.candidate == developer
    end

    def conversation
      Conversation.find_by(developer:, business:)
    end

    delegate :share_url, to: :developer
  end
end
