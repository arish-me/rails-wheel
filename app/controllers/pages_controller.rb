class PagesController < ApplicationController
  layout "auth"

  def index
    redirect_to dashboard_path if user_signed_in?
  end

  def pricing
    # Pricing page action
  end

  def contact
    # Contact page action
  end

  def features
    # Features page action
  end

  def about
    # About page action
  end

  def privacy_policy
    # Privacy Policy page action
  end

  def terms_of_service
    # Terms of Service page action
  end

  def talent_search
    # Talent Search page action (to be implemented later)
    redirect_to public_jobs_path
  end
end
