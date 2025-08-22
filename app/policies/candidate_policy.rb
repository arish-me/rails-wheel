class CandidatePolicy < ApplicationPolicy
  def index?; end

  def show?; end

  def edit?
    record_owner?
  end

  def create?; end

  def update?
    record_owner?
  end

  def destroy?
    record_owner?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
