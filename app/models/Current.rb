class Current < ActiveSupport::CurrentAttributes
  def user
    current_user
  end

  def impersonated_user
    session&.active_impersonator_session&.impersonated
  end

  def true_user
    session&.user
  end
end
