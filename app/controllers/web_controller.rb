class WebController < ApplicationController

    def roadside_assistance
    #@current_user = current_user

    end

    def show
        @rfa = Rfa.new
    end

    private

end
