class JobPolicy < ApplicationPolicy
  def index?
    user.company.present?
  end

  def show?
    # Users can view jobs from their own company
    return true if user.company == record.company

    # Users can view published jobs from other companies
    return true if record.published? && record.active?

    false
  end

  def create?
    user.company.present? && user.can?(:create, "Job")
  end

  def update?
    user.company == record.company && user.can?(:update, "Job")
  end

  def destroy?
    user.company == record.company && user.can?(:destroy, "Job")
  end

  def publish?
    user.company == record.company && user.can?(:publish, "Job")
  end

  def close?
    user.company == record.company && user.can?(:close, "Job")
  end

  class Scope < Scope
    def resolve
      if user.platform_admin?
        scope.all
      elsif user.company.present?
        scope.where(company: user.company)
      else
        scope.none
      end
    end
  end
end
