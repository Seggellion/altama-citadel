class AppAcu < ApplicationRecord

    def self.twitchToken

        client_id = '2xyrq957vyeyn97lswqifrdpneqjju'
        client_secret = 'xgeqj9r3xbswku1p6cyvcysjvxst2u'
        redirect_uri = 'http://localhost:3000'
        scopes = ["channel","read", "redemptions"] # Add any other scopes you need here
        response_type = "code"
        token_uri = URI.parse('https://id.twitch.tv/oauth2/token')
        # Set the headers and parameters for the request
        headers = {
        'Content-Type' => 'application/x-www-form-urlencoded'
        }
        params = {
        'client_id' => client_id,
        'client_secret' => client_secret,
        'grant_type' => 'client_credentials'
        }

        #uri = "https://id.twitch.tv/oauth2/token"


        # Make the request and parse the response
        response = Net::HTTP.post_form(token_uri, params)
        response_json = JSON.parse(response.body)

        # Extract the access token from the response
        access_token = response_json['access_token']

        return access_token




    end




    def self.getTokens





        # Set your Twitch API credentials and channel ID
        client_id = '2xyrq957vyeyn97lswqifrdpneqjju'
        client_secret = 'xgeqj9r3xbswku1p6cyvcysjvxst2u'
        channel_id = '136591885'
        scopes = ['channel','read','redemptions']
        string_scope = 'channel:read:redemptions'
        redirect_uri = 'http://localhost:3000'

        #auth_url = "https://id.twitch.tv/oauth2/token?" + URI.encode_www_form({
        #  :client_id => client_id,
        #  :client_secret => client_secret,
        #  :grant_type => 'client_credentials'
        #})

        # auth_response = URI.open(auth_url).read
        # auth_data = JSON.parse(auth_response)
        # access_token = auth_data["access_token"]
        # use the access_token to make API requests
        # 

        # Generate a new OAuth token
        auth_uri = URI('https://id.twitch.tv/oauth2/token')
        token_uri = URI.parse('https://id.twitch.tv/oauth2/token')
        auth_params = {
        'client_id' => client_id,
        'client_secret' => client_secret,
        # 'grant_type' => 'authorization_code',
        'response_type' => 'code',
        'redirect_uri' => redirect_uri,
        'grant_type' => 'client_credentials',
        # 'scope' => scopes.join(" "),
        'scope' => string_scope
        }

        # byebug
        auth_response = Net::HTTP.post_form(token_uri, auth_params)

        #auth_uri.query = URI.encode_www_form(auth_params)
        # auth_response = Net::HTTP.get_response(auth_uri)

        auth_json = JSON.parse(auth_response.body)
        oauth_token = auth_json['access_token']

        # Set the Twitch API endpoint for getting channel points for a specific channel
        points_uri = URI("https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=#{channel_id}")

        # Set the headers for the request
        headers = {
        'Authorization' => "Bearer #{oauth_token}",
        'Client-ID' => client_id
        }

        # Make the request and parse the response
        points_response = Net::HTTP.get_response(points_uri, headers)
        points_json = JSON.parse(points_response.body)
        byebug
        # Extract the reward IDs from the response
        reward_ids = points_json['data'].map { |reward| reward['id'] }

        # Set the Twitch API endpoint for getting channel points for a specific reward
        redeem_uri = URI("https://api.twitch.tv/helix/channel_points/custom_rewards/redemptions?broadcaster_id=#{channel_id}&reward_id=#{reward_ids.join(',')}&status=UNFULFILLED")

        # Make the request and parse the response
        redeem_response = Net::HTTP.get_response(redeem_uri, headers)
        redeem_json = JSON.parse(redeem_response.body)

        # Extract the user IDs from the response
        user_ids = redeem_json['data'].map { |redeem| redeem['user_id'] }.uniq

        # Set the Twitch API endpoint for getting user information
        user_uri = URI("https://api.twitch.tv/helix/users?id=#{user_ids.join(',')}")

        # Make the request and parse the response
        user_response = Net::HTTP.get_response(user_uri, headers)
        user_json = JSON.parse(user_response.body)

        # Create a hash of user information indexed by user ID
        users = {}
        user_json['data'].each { |user| users[user['id']] = user }

        # Print the username and point balance for each user
        redeem_json['data'].each do |redeem|
        user_id = redeem['user_id']
        user = users[user_id]
        username = user['display_name']
        points = redeem['reward']['cost']
        puts "#{username}: #{points} points"
        end

    end


    BASE_URL = 'https://www.streamlabs.com/api/v2.0'
    def self.StreamlabsPoints
        client_id = "867c09b4-030a-48cd-987f-cd636d85981d"
        client_secret = "v7C6L4iipCPGOXmNiKl7DamOMQKQpLE70zWL2hdD"
        token = "A6CAE49299918B7E93E867DA8911E108550835E072A1E3BEDFFC5B95AA761985BFB5CF49C2DD774346DB72F2AC14C8CD904DFD3AB23DAC4BAB4E6AE3523EC52022859E273D13AEED7BC5CBCC912231833D4770FD410E03C5ECB3915A709080DC995EF41E3FDC768D54685EDC2C28B20D7519894D40D4539F0324907454"
        username="Seggellion"
        redirect_uri = 'http://localhost:3000'
        token_uri = URI.parse('https://streamlabs.com/api/v2.0/token')
        channel = '136591885'

@access_token = token
page =  1





url = URI("https://streamlabs.com/api/v2.0/points?access_token=#{@access_token}&username=#{username}&channel=#{username}")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)

response = http.request(request)
puts response.read_body

byebug



uri = URI("#{BASE_URL}/points?username=#{username}&channel=#{username}")
request = Net::HTTP::Get.new(uri)
request["accept"] = 'application/json'
request["Bearer"] = @access_token

response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
  http.request(request)
end

byebug

            

            def initialize(access_token)
            @access_token = access_token
            super()
            end
        
            def get_points(page = 1)
                uri = URI("#{BASE_URL}/points?access_token=#{@access_token}&page=#{page}")
                response = Net::HTTP.get_response(uri)
            
                if response.code == '200'
                    JSON.parse(response.body)
                else
                    raise "Error fetching points: #{response.code} - #{response.message}"
                end
            end

byebug



    end



end
