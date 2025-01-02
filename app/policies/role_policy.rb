class RolePolicy < ApplicationPolicy
  def index?
    can_view? || can_edit?
  end

  def show?
    can_view? || can_edit?
  end

  def edit?
    can_edit?
  end

  def create?
    can_edit?
  end

  def update?
    can_edit?
  end

  def destroy?
    can_edit?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
