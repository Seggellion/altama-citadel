class WebController < ApplicationController

    def roadside_assistance
    #@current_user = current_user
    
@all_planets = Location.all_planets


    end

    def show
        @userships = current_user.userships
        @usership = Usership.new
        @ships = Ship.all
        @location = Location.find_by_id(params[:location])
        # @active_rfa = Rfa.where(user_id: current_user, status_id: 0).first

        if current_user
        user_tickets = Rfa.where(user_id: current_user.id)
        @active_rfa = user_tickets.where.not(status_id:4).first
        end
        @rfa = Rfa.new
        @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
    end

    private

end
