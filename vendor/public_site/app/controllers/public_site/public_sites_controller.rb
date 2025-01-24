module PublicSite
  class PublicSitesController < ApplicationController
    before_action :set_client

    def show
      # Fetch the requested template and its layout
      @template = @client.templates.find_by(name: params[:template] || "Homepage Template")
      @layout = @template&.layout

      # Render the content
      rendered_template = Liquid::Template.parse(@template.content).render(
        'client' => @client.as_json,
        'courses' => Course.all.as_json(only: [:id, :title, :description])
      )

      if @layout
        rendered_content = Liquid::Template.parse(@layout.content).render(
          'client' => @client.as_json,
          'content' => rendered_template
        )
      else
        rendered_content = rendered_template
      end

      render html: rendered_content.html_safe
    end

    private

    def set_client
      @client = Client.find_by!(subdomain: request.subdomain)
    rescue ActiveRecord::RecordNotFound
      render plain: "Subdomain not found", status: :not_found
    end
  end
end
