class RfaProductsController < ApplicationController
    before_action :set_rfa_product, only: %i[edit update destroy ]
  
  def create
      @rfa_product = RfaProduct.new(rfa_product_params)
      
  
      respond_to do |format|
        if @rfa_product.save
          format.html { redirect_to desktop_path, notice: "rfa_product was successfully created." }
          format.json { render :show, status: :created, location: @rfa_product }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @rfa_product.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def destroy
  
      
      @rfa_product.destroy
      respond_to do |format|
        format.html { redirect_to desktop_path, notice: "Removed rfa_product" }
        format.json { head :no_content }
      end
    end
  
    private
  
    def set_rfa_product
      @rfa_product = RfaProduct.find(params[:id])
      
    end
  
  
  def rfa_product_params
    params.require(:rfa_product).permit(:name, :price, :symbol) 
  end
  
  
  end