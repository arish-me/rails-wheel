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

  def authorize_job_access?
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

  def publish?
    can_edit?
  end

  def close?
    can_edit?
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
