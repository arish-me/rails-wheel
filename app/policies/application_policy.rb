# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def can_view?
    has_permission?(:view)
  end

  def can_edit?
    has_permission?(:edit)
  end

  private

  def has_permission?(action)
    return false unless user

    resource_name = resolve_resource_name

    user.roles.joins(role_permissions: :permission).exists?(
      role_permissions: {
        action: RolePermission.actions[action]
      },
      permissions: {
        resource: resource_name
      }
    )
  end

  def resolve_resource_name
    excluded_classes = [ "Class" ] # List of class names to exclude

    resource_name = if record.is_a?(ActiveRecord::Relation)
                      record.klass.name # For collections
    elsif record.is_a?(Class)
                      record.name # For Class objects (e.g., Category)
    else
                      record.class.name # For single records
    end

    excluded_classes.include?(resource_name) ? "" : resource_name
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
