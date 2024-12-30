# frozen_string_literal: true

class Permission < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions
end
