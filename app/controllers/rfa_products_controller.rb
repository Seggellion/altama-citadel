class RfaProductsController < ApplicationController
    before_action :set_rfa_product, only: %i[edit update destroy ]
  
  def create
      @rfa_product = RfaProduct.new(rfa_product_params)
      binding.break
  
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


    def update
      @rfa = Rfa.find_by_id(@rfa_product.rfa_id)
  
      
      unless @rfa_product.selling_price == 0
      respond_to do |format|
          if @rfa_product.update(rfa_product_params)
              format.html { redirect_to edit_rfa_path(@rfa), notice: "Rfa was successfully updated." }
          end
      end
    else
      service_fee =  (@rfa.servicefee.to_f / 10.00).round(2)
      market_price = @rfa_product.market_price 
      service_fee_total = market_price * service_fee
      selling_price = market_price
      if discounts = @rfa.user.discounts / 100.00      
      discount_price = market_price - (market_price * discounts) 
      
      selling_price = (discount_price + service_fee_total )
      end
      
      params[:rfa_product][:selling_price] = selling_price
      respond_to do |format|
        if @rfa_product.update(rfa_product_params)
            format.html { redirect_to edit_rfa_path(@rfa), notice: "Rfa was successfully updated." }
        end
    end
    end
  end

  
    def destroy
  binding.break
      
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
    params.require(:rfa_product).permit(:name, :price, :symbol, :selling_price, :commodity_id) 
  end
  
  
  end