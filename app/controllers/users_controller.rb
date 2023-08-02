class UsersController < ApplicationController
  protect_from_forgery with: :null_session

   # def index
    #    @users = User.all
    #end

def index
  @department = Department.find(params[:department_id])
  @users = @department.users # Fetch users as needed
  render json: @users
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

# def twitch_redirect
#   tokens = TwitchOAuth2::Tokens.new(
#     client: {
#       client_id: ENV['TWITCH_CLIENT_ID'],
#       client_secret: ENV['TWITCH_CLIENT_SECRET'],
#       redirect_uri: twitch_verify_url(host: request.host)
#     },
#     token_type: :user,
#     scopes: ['user:read:email']
#   )
#   redirect_to tokens.authorize_link
# end

def twitch_redirect
 client = TwitchOAuth2::Client.new(
   client_id: ENV['TWITCH_CLIENT_ID'],
   client_secret: ENV['TWITCH_CLIENT_SECRET'],
    redirect_uri: ENV['TWITCH_REDIRECT_URI']
  )
  
  modify_task = current_user.task_manager.tasks.find_by(name: "User profile").update(state:'twitch-verify')
  
 tokens = TwitchOAuth2::Tokens.new(client: client, token_type: :user, scopes: ['user:read:email'])
  twitch_oauth_url = tokens.authorize_link
  Rails.logger.info "Redirecting to Twitch: #{twitch_oauth_url}"
  
  redirect_to twitch_oauth_url, allow_other_host: true
end

def twitch_verify
  code = params[:code]
  
  tokens = TwitchOAuth2::Tokens.new(
    client: {
      client_id: ENV['TWITCH_CLIENT_ID'],
      client_secret: ENV['TWITCH_CLIENT_SECRET'],
      redirect_uri: ENV['TWITCH_REDIRECT_URI']
    }, 
    token_type: :user, 
    scopes: ['user:read:email']
  )
  tokens.code = code
  access_token = tokens.access_token
  

  current_task = Task.find_by_state("twitch-verify")
  current_user = current_task.task_manager.user
  current_task.update(state:'')


  url = URI("https://api.twitch.tv/helix/users")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Client-ID"] = ENV['TWITCH_CLIENT_ID']
  request["Authorization"] = "Bearer #{access_token}"

  response = http.request(request)

  user_info = JSON.parse(response.body)['data'].first
  
  current_user.update(
    twitch_username: user_info['login'],
    twitch_id: user_info['id']
  )
  current_task.memo(memo_type: "error", memo_text:"Successfully linked your Twitch account!")
  
  redirect_to root_url, allow_other_host: true
end

# def twitch_verify
#   tokens = TwitchOAuth2::Tokens.new(
#     client: {
#       client_id: ENV['TWITCH_CLIENT_ID'],
#       client_secret: ENV['TWITCH_CLIENT_SECRET'],
#       redirect_uri: twitch_verify_url(host: request.host)
#     },
#     token_type: :user,
#     scopes: ['user:read:email']
#   )
#   tokens.code = params[:code]
#   twitch_client = Twitch::Client.new(tokens: tokens)

#   user_info = twitch_client.get_users.data.first

#   current_user.update(
#     twitch_username: user_info.login,
#     twitch_id: user_info.id
#   )

#   redirect_to root_path, notice: "Successfully linked your Twitch account!"
# end



def discord_populate
  
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