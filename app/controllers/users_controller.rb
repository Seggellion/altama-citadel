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
  
  information = request.raw_post
data_parsed = JSON.parse(information)

DiscordUser.destroy_all

DiscordUser.create(data_parsed)


end

    def verify
        user = User.find_by_id(params[:user])
        rfa = Rfa.find_by(user_id:user.id, status_id: 1)
        hash = params[:hash]
        
        if  RsiUser.authenticate(hash,user.id, params[:handle]) && user.user_type != 1202
   
          redirect_to edit_rfa_path(rfa), notice: "Successfully verified user."
        else
 
          redirect_to edit_rfa_path(rfa), notice: "Sorry we couldn't verify your account please try again."
        end


    end

end