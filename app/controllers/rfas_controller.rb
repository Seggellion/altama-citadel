class RfasController < ApplicationController
  before_action :set_rfa, only: %i[edit update destroy ]
  before_action :require_login

  # GET /rfas or /rfas.json
  def index
    @rfas = Rfa.where(status_id:1)
    @rfas += Rfa.where(status_id:0)
    @rfas += Rfa.where(status_id:2)
    @rfa_hold = Rfa.where(status_id:3)
    @rfa_solved = Rfa.where(status_id:4)
    @rfa_unassigned = Rfa.where(status_id:0)
    @rfa_mine = Rfa.where(user_assigned_id: current_user.id)

    @current_task = Task.find_by(name: "RFA Manager")
  end

  
def online
  
  user = current_user

#user.update()
eligible_rfas = Rfa.where("status_id < ?", 2)
if user.online_status == "rfa_online"
  user.update(online_status: nil)
  if User.where(online_status:"rfa_online").empty?
    eligible_rfas.update_all(users_online:false)
    end

else
  
  
  if User.where(online_status:"rfa_online").empty?
    
    
    eligible_rfas.update_all(users_online:true)
  #  Rfa.update_all(users_online:true)
  
  end
  user.update(online_status: "rfa_online")
end

  respond_to do |format|
    if user.online_status

      format.html { redirect_to rfas_path, notice: "User is online" }
      #format.json { render :show, status: :created, location: @rfa }
    else
      format.html { redirect_to rfas_path, notice: "User is offline" }
      
    end
  end
  
end

  # GET /rfas/new
  def new
    @rfa = Rfa.new
  end

  # GET /rfas/1/edit
  def edit
    
    @all_commodities = Commodity.all
    @all_locations = Location.all
    @all_products = RfaProduct.all
    @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
  end

  # POST /rfas or /rfas.json
  def create

    @rfa = Rfa.new(rfa_params)
    @usership = Usership.new
    @userships = Usership.where(user_id: current_user.id)
    @location = Location.find_by_id(@rfa.location_id)
    @ships = Ship.all

    respond_to do |format|
      if @rfa.save

        embed = Discord::Embed.new do |location_name|
          rfa = Rfa.last
          title "ΛLTΛMΛ Citadel - New request for assistance - Click here to view"
          description "@here Please view this RFA within Citadel"
          
          location = Location.find_by_id(rfa.location_id)
          author name: rfa.user.username
          color "00FFFF"
          
          url "https://ctd.altama.energy/rfas/#{rfa.id}/edit"
          add_field name: "Location",
                    value: location.name
          add_field name: "Ship",
                    value: rfa.full_ship_name
          footer text: "<#dispatch>"
                image url:'https://i.pinimg.com/originals/ab/0a/5d/ab0a5d652bec1e632019c20edbc0444a.jpg'
        end
        
        
        Discord::Notifier.message(embed)    
        format.html { redirect_to rfa_location_path(location: @location), notice: "Rfa was successfully created." }
        #format.json { render :show, status: :created, location: @rfa }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rfa.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rfas/1 or /rfas/1.json
  def update
    
    user = User.find_by_id(@rfa.user_id)
    # Discord::Notifier.message('!update user: <@'+ user.uid + '>' )
    status = Rfa.get_status(params[:rfa][:status_id].to_i) 
    service_fee =  (params[:rfa][:servicefee].to_f / 10.00).round(2)

  #  assigned_user = User.find_by_id(rfa_params[:user_assigned_id])
  @aec = 0
  
    bot_url = "https://altama-energy-support.herokuapp.com/"

    bot =  Nokogiri::HTML(URI.open(bot_url).read)

    if params[:rfa][:HYD].to_f > 0
      commodity = Commodity.find_by(symbol:"HYD")
      amount =  params[:rfa][:HYD].to_f
      market_price = commodity.price
      service_fee_total = market_price * service_fee
      discounts = user.discounts / 100.00
      discount_price = market_price - (market_price * discounts)
      selling_price = (discount_price + service_fee_total ) * amount

      #@aec = @aec + (selling_price * (Reward.apply('aec')/100.00)).ceil
      if @rfa.commodities.find_by_id(commodity)
        rfa_product = RfaProduct.find_by(commodity_id: commodity.id)
        rfa_product.update(amount: amount, selling_price: selling_price, market_price: market_price)
      else
        RfaProduct.create(commodity_id: commodity.id, amount: amount, rfa_id:@rfa.id,
        market_price: market_price, selling_price: selling_price )
      end
    end

  if params[:rfa][:QNT].to_f > 0
    commodity = Commodity.find_by(symbol:"QNT")
    amount =  params[:rfa][:QNT].to_f
    market_price = commodity.price
    service_fee_total = market_price * service_fee
    discounts = user.discounts / 100.00
    discount_price = market_price - (market_price * discounts) 
    selling_price = (discount_price + service_fee_total ) * amount
if Reward.find_by(title:'aec')
    @aec = @aec + (selling_price * (Reward.apply('aec')/100.00)).ceil
end
   if @rfa.commodities.find_by_id(commodity)
    
    rfa_product = RfaProduct.find_by(rfa_id: @rfa.id,commodity_id: commodity.id)
    rfa_product.update(amount: amount, selling_price: selling_price, market_price: market_price)
    
   else
    RfaProduct.create(commodity_id: commodity.id, amount: amount, rfa_id:@rfa.id,
    market_price: market_price, selling_price: selling_price )
   end
  end
  
  
  merge_params = rfa_params.merge(aec_rewards: @aec)
  if rfa_params[:user_assigned_id].blank?
    merge_params = rfa_params.merge(status_id: 0)
  end
  
  if status == "Solved"
    user_aec = user.aec + @aec
    user.update(aec: user_aec)
    user.give_karma(2)
    user.give_fame(2)
    current_user.give_karma(5)
    current_user.give_fame(5)
  end
  
    respond_to do |format|
      if @rfa.update(merge_params)
        unless rfa_params[:user_assigned_id].blank?
          Discord::Notifier.message('!update ,'+ user.uid + ',' + status)
        end
        
         #format.turbo_stream { render turbo_stream: turbo_stream.update(@rfa) }
       format.turbo_stream
       
      #  format.turbo_stream { render turbo_stream: turbo_stream.replace("#{helpers.dom_id(@rfa)}_item") }

       # format.turbo_stream do
       #   render turbo_stream: turbo_stream.replace(@rfa, partial: 'web/rfa-status')
      # end
        format.html { redirect_to edit_rfa_path(@rfa), notice: "Rfa was successfully updated." }
      else
        
        format.html { redirect_to edit_rfa_path(@rfa), notice: "Rfa must be assigned to" }
        
        # format.html { render :edit, status: :unprocessable_entity }
        
        #format.json { render json: @rfa.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rfas/1 or /rfas/1.json
  def destroy
    @rfa.destroy
    respond_to do |format|
      format.html { redirect_to rfas_url, notice: "Rfa was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rfa
      @rfa = Rfa.find(params[:id])
      @users = User.all
    end

    # Only allow a list of trusted parameters through.
    def rfa_params
      params.require(:rfa).permit(:title, :description, :rsi_username, :status_id, 
      :location_id, :ship_id, :priority_id, :total_fuel, :total_price, :total_cost, 
      :aec_rewards, :user_assigned_id, :user_id, :usership_id, :servicefee,
      userships_attributes: [:ship_id, :user_id])      
    end
end
