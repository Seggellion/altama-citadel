class ShipComponentsController < ApplicationController
    def index
      @ship_components = ShipComponent.all
      render json: @ship_components
    end
  end
  