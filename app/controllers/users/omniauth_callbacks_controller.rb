class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: :discord
  # skip_before_action :require_login

  # Pineapple
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)  && !resource.isGuest?
     desktop_path
    end
  end

  def discord
    # user = User.find_by_email(request.env["omniauth.auth"].info.email)
    # if user.isTeamOwner?
    #   redirect_to tournaments_path
    # else
    #   redirect_to new_team_path
    # end


    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
# oct 24 this code is broken.
p @user.username
    if @user.persisted?
      p "not an error!"
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?
    else
      p "error!"
      # commented october 24
       session["devise.discord_data"] = request.env["omniauth.auth"].except(:extra) # Removing extra as it can overflow some session stores
       p session["devise.discord_data"]
       #redirect_to new_team_path
       redirect_to root_path, alert: @user.errors.full_messages.join("\n")
    end

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    # @user = User.from_omniauth(request.env["omniauth.auth"])
    # auth = request.env["omniauth.auth"]
    # byebug
    # user_exists = User.find_by_email(@user.email).present?
    # if @user.persisted?
    #   sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
    #   set_flash_message(:notice, :success, kind: "discord") if is_navigational_format?
    # else
    #
    #   session["devise.discord_data"] = request.env["omniauth.auth"].except(:extra) # Removing extra as it can overflow some session stores
    #
    #   usercreate = User.new(
    #      {
    #        :email => auth.info.email,
    #        :password => Devise.friendly_token[0, 20],
    #        :password_confirmation => Devise.friendly_token[0, 20],
    #        :username => auth.info.name,
    #        :profile_image => auth.info.image,
    #        :uid => auth.uid,
    #        :provider => auth.provider
    #        })
    #        usercreate.save
    #        user = User.find_by(username: auth.info.name)
    #        redirect_to new_team_path
    # end
  end

  def failure
    redirect_to root_path
  end
end
