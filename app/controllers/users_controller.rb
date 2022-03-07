class UsersController < ApplicationController

    def index
        @users = User.all
    end

    def auth

        require 'net/http'
        require 'uri'
        @hash = params[:hash]
        uri = URI.parse("https://robertsspaceindustries.com/citizens/#{params[:handle]}")
        response = Net::HTTP.get_response(uri)
        # render plain: params[:handle].inspect
        @body = response.body
    
        if response.body.include? @hash
          current_user.update(rsi_verified: 1)
          current_user.update(rsi_profile: params[:handle])
          # current_user.handle = params[:handle]
          redirect_to edit_user_registration_path(current_user), notice: "Successfully verified user."
        else
          # redirect_to my_rsi_handle_path, notice: @body
          # @handle = params[:handle]
          # redirect_to my_rsi_handle_path, notice: params[]
          redirect_to edit_user_registration_path(current_user), notice: "Sorry we couldn't verify your account please try again."
        end
        

    end

end