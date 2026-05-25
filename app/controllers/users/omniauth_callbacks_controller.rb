class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

skip_before_action :verify_authenticity_token, only: [:discord, :failure]

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
        root_path
      end
    else
      super # call Devise's implementation if resource is not a User
    end
  end

  def discord
    @user = User.from_omniauth(request.env["omniauth.auth"], request.env["omniauth.params"])

    if @user.persisted?
      session[:username] = @user.username
      sign_in @user, event: :authentication
      
      # Set flash message before redirecting
      set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?

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
    else
      # Log the exact validation errors to your Heroku logs for debugging
      Rails.logger.error("Discord Login Failed - User Errors: #{@user.errors.full_messages.join(', ')}")
      
      # DO NOT store the entire auth hash to avoid CookieOverflow crashes
      # We only store the basic provider and uid safely
      session["devise.discord_data"] = request.env["omniauth.auth"].slice(:provider, :uid)
      
      redirect_to root_path, alert: "Login failed: #{@user.errors.full_messages.join(', ')}"
    end
  end

  def failure
    redirect_to root_path, alert: "Discord authentication was canceled or failed."
  end
end