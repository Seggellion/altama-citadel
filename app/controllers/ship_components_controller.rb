class ShipComponentsController < ApplicationController
    def index
        if params[:type]
            @ship_components = ShipComponent.where(component_type: params[:type])
          else
            @ship_components = ShipComponent.all
          end      
      render json: @ship_components
    end
  end
  