class UsersController < ApplicationController
  protect_from_forgery with: :null_session

    def index
        @users = User.all
    end

def activate
  user = User.find_by_id(params[:user])
  hash = params[:hash]
  if  RsiUser.authenticate(hash,user.id, params[:handle]) 
    redirect_to desktop_path, notice: "Successfully verified user."
  else
    redirect_to desktop_path, notice: "Failed."
  end
end

def discord_populate
  byebug
  information = request.raw_post
  data_parsed = JSON.parse(information)

  DiscordUser.destroy_all

  DiscordUser.create(data_parsed)
end

    def verify
          hash = params[:hash]

          url = request.env["HTTP_REFERER"]
          uri = URI::parse(url)
          static_params = CGI::parse(uri.query)

        @location = Location.find_by_id(static_params['location'])
        rfa = Rfa.find_by(user_id:current_user.id, status_id: 1)
        
        if  RsiUser.authenticate(hash, current_user.id, params[:user])          
          redirect_to rfa_location_path(location: @location.id), notice: "Successfully verified user."
        else
          
          redirect_to rfa_location_path(location: @location.id), notice: "Sorry we couldn't verify your account please try again."
        end
    end


def admin_verify
  hash = params[:hash]

  rfa = Rfa.find_by(user_id:current_user.id, status_id: 1)

  if  RsiUser.authenticate(hash,current_user.id, params[:handle])
    
    redirect_to edit_rfa_path(rfa), notice: "Successfully verified user."
  else

rfa = Rfa.find_by(user_id:current_user.id, status_id: 1)
    redirect_to edit_rfa_path(rfa), notice: "Sorry we couldn't verify your account please try again."
  end

end


end