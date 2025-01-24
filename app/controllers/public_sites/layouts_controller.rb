module PublicSite
  class LayoutsController < ApplicationController
    before_action :set_client
    before_action :set_layout, only: [:edit, :update, :destroy]

    def index
      @layouts = @client.layouts
    end

    def new
      @layout = @client.layouts.new
    end

    def create
      @layout = @client.layouts.new(layout_params)
      @layout.client = @client
      if @layout.save
        redirect_to client_public_site_layouts_path(@client), notice: 'Layout created successfully.'
      else
        render :new
      end
    end

    def edit; end

    def update
      if @layout.update(layout_params)
        redirect_to client_public_site_layouts_path(@client), notice: 'Layout updated successfully.'
      else
        render :edit
      end
    end

    def destroy
      @layout.destroy
      redirect_to client_public_site_layouts_path(@client), notice: 'Layout deleted successfully.'
    end

    private

    def set_client
      @client = Client.find(params[:client_id])
    end

    def set_layout
      @layout = @client.layouts.find(params[:id])
    end

    def layout_params
      params.require(:layout).permit(:name, :content)
    end
  end
end
