# frozen_string_literal: true

class UserRole < ApplicationRecord
  acts_as_tenant(:account)
  belongs_to :user
  belongs_to :role
  belongs_to :account

  validates :role_id, uniqueness: { scope: :user_id, message: 'can only be assigned once per user' }
end
