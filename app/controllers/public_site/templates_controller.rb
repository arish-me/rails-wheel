module PublicSite
  class TemplatesController < ApplicationController
    before_action :set_client
    before_action :set_template, only: [:edit, :update, :destroy]

    def index
      @templates = @client.templates
    end

    def new
      @template = @client.templates.new
    end

    def create
      @template = @client.templates.new(template_params)
      @template.client = @client
      if @template.save
        redirect_to client_public_site_templates_path(@client), notice: 'Template created successfully.'
      else
        render :new
      end
    end

    def edit; end

    def update
      if @template.update(template_params)
        redirect_to client_public_site_templates_path(@client), notice: 'Template updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @template.destroy
      redirect_to client_public_site_templates_path(@client), notice: 'Template deleted successfully.'
    end

    private

    def set_client
      @client = Client.find(params[:client_id])
    end

    def set_template
      @template = @client.templates.find(params[:id])
    end

    def template_params
      params.require(:template).permit(:name, :content, :layout_id)
    end
  end
end
