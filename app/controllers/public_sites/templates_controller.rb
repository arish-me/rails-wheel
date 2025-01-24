module PublicSites
  class TemplatesController < ApplicationController
    before_action :set_client
    before_action :set_template, only: [:edit, :update, :destroy]

  def index
    if params[:query].present?
      @pagy, @templates = pagy(@client.templates.search_by_name(params[:query]), limit: params[:per_page] || "10")
    else
      @pagy, @templates = pagy(@client.templates, limit: params[:per_page] || "10")
    end
  end

    def new

      @template = @client.templates.new
    end

    def create
      @template = @client.templates.new(template_params)
      @template.client = @client
      if @template.save
        redirect_to client_templates_path(@client), notice: 'Template created successfully.'
      else
        render :new
      end
    end

    def edit; end

    def update
      if @template.update(template_params)
        redirect_to client_templates_path(@client), notice: 'Template updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @template.destroy
      redirect_to client_templates_path(@client), notice: 'Template deleted successfully.'
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
