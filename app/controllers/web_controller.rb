class WebController < ApplicationController

    def roadside_assistance
    #@current_user = current_user
    
@all_planets = Location.all_planets


    end

    def show
        @ships = Ship.all
        @location = Location.find_by_id(params[:location])
        @rfa = Rfa.new
        @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
    end

    private

end
