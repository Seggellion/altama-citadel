class CommodityController < JSONAPI::ResourceController
   # skip_before_action :verify_authenticity_token
   #byebug

   def update
      
    @commodity = Commodity.find(params[:id])

    if @commodity.update(commodity_params)
      flash[:notice] = 'Commodity was successfully updated.'
      redirect_to commodities_path
    else
      flash.now[:alert] = 'Error updating commodity!'
      render :edit
    end

  end

  private

  def commodity_params
    params.require(:commodity).permit(:vices, :sell, :buy)
  end


end