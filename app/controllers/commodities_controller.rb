class CommoditiesController < ApplicationController
    before_action :set_commodity, only: %i[edit update destroy ]
  
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
    params.require(:commodity).permit(:name, :price, :symbol) 
  end
  
  
  end