module PermissionHelper
  def create_user_with_permission(user_type: :super_admin, resource: nil, action: :edit, company: nil)
    company ||= create(:company)
    user = create(:user, :onboarded)
    user.update!(company: company)

    # Create role with the same company context (handling multi-tenancy)
    ActsAsTenant.current_tenant = company
    user_type.to_s.classify
    role = create("#{user_type}_role", company: company)
    create(:user_role, user: user, role: role)

    if resource && action
      permission = create(:permission, resource: resource)
      create(:role_permission, action, role: role, permission: permission, company: company)
    end

    # Reset tenant
    ActsAsTenant.current_tenant = nil

    user
  end

  def create_super_admin_with_edit_permission(resource, company: nil)
    create_user_with_permission(
      user_type: :super_admin,
      resource: resource,
      action: :edit,
      company: company
    )
  end

  def create_admin_with_edit_permission(resource, company: nil)
    create_user_with_permission(
      user_type: :admin,
      resource: resource,
      action: :edit,
      company: company
    )
  end

  def create_user_with_view_permission(user_type: :super_admin, resource: nil, company: nil)
    create_user_with_permission(
      user_type: user_type,
      resource: resource,
      action: :view,
      company: company
    )
  end
end

RSpec.configure do |config|
  config.include PermissionHelper
end
