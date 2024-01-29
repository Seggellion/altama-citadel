class ShipComponentsController < ApplicationController
    def index
        if params[:type]
            @ship_components = ShipComponent.where(component_type: params[:type])
          else
            @ship_components = ShipComponent.all
          end      
      render json: @ship_components
    end


    def assign_components
      # Fetch today's StarBitizenRaceUsers
      todays_race_users = StarBitizenRaceUser.where("created_at >= ?", Time.zone.now - 24.hours)

      ship_component = ShipComponent.find(params[:ship_component_id])

      ship = Ship.find_by_model(ship_component.ship_model)
dexterity =  (ship.ifcs_pitch_max + ship.ifcs_yaw_max + ship.ifcs_roll_max) / 3
      todays_race_users.each do |race_user|
        # Check if the user already has a 'Mustang Alpha' ship
        usership = Usership.find_or_create_by(user_id: race_user.user_id,
         model: ship.model,
         source: "starbitizen",
        ship_id: ship.id,
        health: ship.hp,
        topspeed: ship.speed,
        dexterity: dexterity)
  
        # Create UsershipComponent
        UsershipComponent.create!(
          usership_id: usership.id,
          ship_components_id: ship_component.id
        )
      end
    end

  end
  