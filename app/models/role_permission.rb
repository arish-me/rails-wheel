# frozen_string_literal: true

class RolePermission < ApplicationRecord
  acts_as_tenant(:account)
  belongs_to :role
  belongs_to :permission

  #enum action, { none: 0, view: 1, edit: 2 }
  enum :action, { view: 0, edit: 1 }
  validates :permission_id, uniqueness: { scope: :role_id, message: 'already assigned to this role' }
end
