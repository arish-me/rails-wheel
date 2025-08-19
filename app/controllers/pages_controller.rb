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
end
