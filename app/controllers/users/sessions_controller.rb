class Users::SessionsController < Devise::SessionsController
  prepend_before_action :find_tenant_by_subdomain
end
