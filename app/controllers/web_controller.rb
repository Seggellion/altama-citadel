class WebController < ApplicationController

    def roadside_assistance
    #@current_user = current_user
    
@leveltwos = Location.where("system = parent")


    end

    def show
@ships = Ship.all
        @location = Location.find_by_id(params[:location])
        @rfa = Rfa.new
    end

    private

end
