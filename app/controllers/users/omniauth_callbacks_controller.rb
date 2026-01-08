class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :discord

  def after_sign_in_path_for(resource)
    subdomain = request.subdomain
    
    if resource.is_a?(User) 
      case subdomain
      when 'ctd'        
        current_user = User.find_by_username(@user.username)
        
        TaskManager.find_or_create_by(user_id: current_user.id)
        bootup_path(subdomain: 'ctd')
      when 'sos'
        roadside_assistance_path(subdomain: 'sos')
      else
        # specify a default path if neither subdomain matches
      end
    else
      super # call Devise's implementation if resource is not a User
    end
  end

  def discord
    
    @user = User.from_omniauth(request.env["omniauth.auth"], request.env["omniauth.params"])

    if @user.persisted?
    #  sign_in_and_redirect @user, event: :authentication 

      session[:username] = @user.username

      sign_in @user, event: :authentication
      captain_username = session.delete(:captain)
      event_id = session.delete(:event_id_for_signup)

      
if captain_username
        # If they came from a /join_crew link, send them back there
        redirect_to join_crew_path(captain_username)
      elsif event_id
        # If they came from an event invite, send them there
        redirect_to invite_path(id: event_id)
      else
        # Default fallback
        redirect_to bootup_path(subdomain: 'ctd')
      end

      set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?
    else
      session["devise.discord_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to root_path, alert: @user.errors.full_messages.join("\n")
    end
  end


  def failure
    redirect_to root_path
  end
end
