# app/controllers/api/v1/star_bitizen_races_controller.rb
module Api
    module V1
      class StarBitizenRacesController < ApplicationController
        # Add any needed before_actions here, e.g., authentication checks
  
        def index
          # Group and count StarBitizenRaceUser records by user
          race_users_by_user = StarBitizenRaceUser.joins(:user).group('users.username').count
  
          # Prepare data for chart - user races
          user_races_data = race_users_by_user.map do |username, count|
            {
              username: username,
              race_count: count
            }
          end
  
          # Group and count StarBitizenRaceUser records by ship
          race_users_by_ship = StarBitizenRaceUser.group(:ship).count
  
          # Prepare data for chart - ship races
          ship_races_data = race_users_by_ship.map do |ship, count|
            {
              ship: ship,
              race_count: count
            }
          end
  
          render json: {
            user_races: user_races_data,
            ship_races: ship_races_data
          }
        end
      end
    end
  end
  