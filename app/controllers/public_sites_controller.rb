class PublicSitesController < ApplicationController
  layout 'public'
  before_action :set_site

  def show
    render template: "public_sites/show", layout: "public"
  end

  # def page
  #   @page = @site.pages.find_by!(slug: params[:slug])
  #   render :show
  # end

  def page
    @page = @site.pages.find_by!(slug: params[:slug])
    # template = "public_sites/#{@page.slug}" # Ensure slug matches template names if applicable
    # render template: template, layout: "public"
    render :show
  end

  private

  def set_site
    @site = Site.includes(:themes).find_by!(subdomain: request.subdomain)
  end
end
