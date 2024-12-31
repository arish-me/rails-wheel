# frozen_string_literal: true

class Role < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  scope :excluding_super_admin, -> { where.not(name: 'SuperAdmin') }
end
