class CommoditiesController < ApplicationController
    before_action :set_commodity, only: %i[edit update destroy ]
  
    def commodities_by_location

      @commodities = Commodity.where(location: params[:location])
      
      render json: @commodities
    end

    def deactivate_commodities
      location = Location.find_by(name: params[:location])
      
      commodity_name = params[:name]
      commodities = Commodity.where(location: location.name, name: commodity_name)
    
      commodities.update_all(active: false)
    
      redirect_to root_path
    end

  def create
      @commodity = Commodity.new(commodity_params)
      
  
      respond_to do |format|
        if @commodity.save
          format.html { redirect_to desktop_path, notice: "commodity was successfully created." }
          format.json { render :show, status: :created, location: @commodity }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @commodity.errors, status: :unprocessable_entity }
        end
      end
    end
  

    def destroy
  
      
      @commodity.destroy
      respond_to do |format|
        format.html { redirect_to desktop_path, notice: "Removed commodity" }
        format.json { head :no_content }
      end
    end
  
    private
  
    def set_commodity
      @commodity = Commodity.find(params[:id])
      
    end
  
  
  def commodity_params
    params.require(:commodity).permit(:name, :price, :symbol, :vice, :buy, :sell) 
  end
  
  
  end