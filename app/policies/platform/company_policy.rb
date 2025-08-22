# app/policies/platform/company_policy.rb
module Platform
  class CompanyPolicy < ApplicationPolicy
    def index?
      user.platform_admin?
    end

    def show?
      user.platform_admin?
    end

    def new?
      user.platform_admin?
    end

    def create?
      user.platform_admin?
    end

    def edit?
      user.platform_admin?
    end

    def update?
      user.platform_admin?
    end

    def destroy?
      user.platform_admin?
    end

    # If you were to use `policy_scope(Company)` outside Active Admin, this would apply.
    # For admin panels, `ActsAsTenant.without_tenant` on `scoped_collection` often overrides this.
    class Scope < Scope
      def resolve
        if user.platform_admin?
          # A platform admin can see all companies (bypassing ActsAsTenant's default scope)
          # Ensure your `Company` model is NOT acts_as_tenant, as it's the tenant itself.
          scope.all # Assuming Company is not tenant-scoped.
        else
          # If not a platform admin, they should not access this scope in the admin panel.
          # This part of the scope might not even be reached if `authorize` is used first.
          scope.none
        end
      end
    end
  end
end
