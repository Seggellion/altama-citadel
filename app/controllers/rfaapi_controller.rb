class RfaapiController < JSONAPI::ResourceController
    skip_before_action :verify_authenticity_token
    
    def create
        
        api_params =  params[:data][:attributes].as_json
        random_password = [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
        users_online = User.where(online_status: "rfa_online")
        ship_name = api_params['ship_name']
        ship = Ship.find_by("lower(model) = ?", ship_name.downcase)
        location_name = api_params['location']
        location = Location.find_by("lower(name) = ?", location_name.downcase)
        
if users_online.empty?
    users_online_boolean = false
else
    users_online_boolean = true
end


    unless user = User.find_by_rsi_username(api_params['rsi_username'])
        User.create(rsi_username: api_params['rsi_username'], password: random_password )
    end

    user = User.find_by_rsi_username(api_params['rsi_username'])
    user_rfa = Rfa.find_by(user_id: user.id, status_id: 0)
    if user_rfa
    @rfa = user_rfa.update(
        location_id: location.id,  
            ship_id: ship.id, 
            rsi_username: user.rsi_username,
            user_id: user.id,
            status_id: 0,
            users_online:users_online_boolean
    )
    render json: user_rfa
    else
        @rfa = Rfa.new(location_id: api_params['location_name'],  
        ship_id: api_params['ship_id'], 
        rsi_username: user.rsi_username,
        user_id: user.id,
        status_id: 0,
        users_online:users_online_boolean )
        @rfa.save     
        render json: @rfa
    end
   
    #@location = Location.find_by_id(@rfa.location_id)


   # if @rfa.save
        
     # embed = Discord::Embed.new do |location_name|
     #   rfa = Rfa.last
     #   title "ΛLTΛMΛ Citadel - New request for assistance - Click here to view"
     #   description "@here Please view this RFA within Citadel"
        
     #   location = Location.find_by_id(rfa.location_id)
     #   author name: rfa.user.username
    #    color "00FFFF"
        
     #   url "https://ctd.altama.energy/rfas/#{rfa.id}/edit"
    #    add_field name: "Location",
     #             value: location.name
    #    add_field name: "Ship",
    #              value: rfa.full_ship_name
    #    footer text: "<#dispatch>"
    #          image url:'https://i.pinimg.com/originals/ab/0a/5d/ab0a5d652bec1e632019c20edbc0444a.jpg'
    #  end
      
    #render json: @rfa, each_serializer: ResponseSerializer, status: :ok
    
     # Discord::Notifier.message(embed)    
   # end
    end

    private
    def rfa_params
        params.require(:rfa).permit(:title, :description, :rsi_username, :status_id, 
        :location, :ship_id, :priority_id, :total_fuel, :total_price, :total_cost, 
        :aec_rewards, :user_assigned_id, :user_id, :usership_id, :servicefee,
        userships_attributes: [:ship_id, :user_id])      
    end

end