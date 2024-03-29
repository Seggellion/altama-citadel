class WebController < ApplicationController
    before_action :website_require_login, only: %i[current_review ]
    def current_review
        @rfa = Rfa.where(status_id: 4, user_id:current_user.id).last
        
        @location = @rfa.location.find_planet

    end

    def roadside_assistance
    #@current_user = current_user
        @all_planets = Location.all_planets
    end

    def show
        if current_user
            @userships = current_user.userships
        end
        @usership = Usership.new
        @ships = Ship.all
        

     #   url = request.url
     #   uri = URI::parse(url)   
     #   urlparams = CGI::parse(uri.query)

        if params[:location]
        @location = Location.find_by_id(params[:location])
        else
            @location = Location.find_by_id(params[:format])
        end
        
        # @active_rfa = Rfa.where(user_id: current_user, status_id: 0).first
        @review = Review.new

        if current_user
        user_tickets = Rfa.where(user_id: current_user.id)
        @active_rfa = user_tickets.where.not(status_id:4).first
        end
        @rfa = Rfa.new
        @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
    end

    private

end
