class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :omniauthable, omniauth_providers: %i[discord]
  has_many :userships
  #has_many :ships, :through => :userships
  has_many :ships, through: :userships, source: :ship, foreign_key: 'model'

  has_one :task_manager
  has_many :rfas
  has_many :messages
  has_one :position, :through => :user_position
  has_one :user_position
  
  def top_five
    userships = self.userships
end

  def email_required? 
    false 
  end 

  def app_present?
    task_manager = TaskManager.find_by(user_id: self.id)
    if task_manager.tasks
        return true
    end
end

def isAdmin?
  if self.user_type == 0
    return true
  else
    return false
  end
end

def desktop
  
  self.update(last_login: DateTime.now)
end

def discounts
  discount = 0
  if self.verified?
  discount =+ 5
  end
  
  discount
end



  def will_save_change_to_email?
    false
   end
  
   def email_changed?
    false
   end

  def voted?(role)
    if OrgRoleVote.where(user_id: self.id, org_role_id: role.id).present?
      return true
    else
      return false
    end
  end


    def get_userships

      self.joins(:ships).select("userships.*, ships.model")
      #Division.where(race_id: race.id).joins(:division_joins)

    end

    def discord_role
      discord_user = DiscordUser.find_by(username: self.username)
      if discord_user && !discord_user.role.nil?
        discord_user.role
      else
        "Nosync"
      end
    end

   def user_type_text
    if self.user_type == 0
      p 'Administrator'
    elsif self.user_type == 10
      p 'Board Member'
    elsif self.user_type == 15
      p 'Executive'
    elsif self.user_type == 20
      p 'Partner'
    elsif self.user_type == 25
      p 'Flight Crew'
    elsif self.user_type == 30
      p 'Worker Owner'
    elsif self.user_type == 42
      p 'Member Owner'
    elsif self.user_type == 100
      p 'Altama Plus'
    else
      p 'Guest'
    end

   end

   def has_open_ticket?
    user_tickets = Rfa.where(user_id: self.id)
    open_tickets = user_tickets.where.not(status_id:4)

    if !open_tickets.empty?
      return true
    end
   end

   def isGuest?
    return false
    if self.user_type > 100
      return true
    end
  end

 

  def isPlus?
    if self.user_type == 100
      return true
    end
  end

  def ship_count(ship)
    all_ships = Usership.where(user_id: self.id, ship_name: ship.model)
    all_ships.count
  end

  def primary_ship
    primary_ship = Usership.find_by(user_id: self.id, primary:1)
   if primary_ship
    return primary_ship.ship.model
  else
    return false
  end

  end

    def self.from_omniauth(auth, params)
      
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.user_type = 101 
      if params["plus"] == "true"
        user.user_type = 100 
      end
      user.password = Devise.friendly_token[0, 20]
      user.username = auth.info.name   # assuming the user model has a name
      user.profile_image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    
    end

  end
  def self.new_with_session(params, session)

    super.tap do |user|
      if data = session["devise.discord_data"] && session["discord.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.username = data["username"] if user.email.blank?
      end
    end
  end
  
  def guildstone_messages
    self.my_messages.where(read:false, task_id:"Guildstone").count
  end

  def my_messages
    Message.where(user_id: self.id)
  end


  def past_messages_users
    #self.my_messages.select(:sender_id).distinct
#    self.my_messages.pluck(:task_id).uniq

  #  unique_messages = self.my_messages.group_by(&:task_id).each_with_object({}) do |messages, hash|
  #    messages[0] = messages[1].max_by{|v| v.created_at}
  #  end
  #  unique_messages


    
      subquery = self.my_messages.select('MAX(id) as id').group(:task_id)
      self.my_messages.where(id: subquery)
        
    



  end

  def fetch_user_currency(twitch_username)
    params = {
      'broadcaster_id' => get_user_id(AppAcu.get_user_id(twitch_username)),
      'only_manageable_rewards' => true
    }
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Authorization' => "Bearer #{AppAcu.twitchToken}"
    }
    # Make the request and parse the response
    response = Net::HTTP.get_response(URI.parse("https://api.twitch.tv/helix/channel_points/custom_rewards?#{params.to_query}"), headers)
    response_json = JSON.parse(response.body)

    # Find the user's custom reward with the code '!aec'
    reward = response_json['data'].find { |reward| reward['cost'] == 1 && reward['title'] == '!aec' }

    if reward
      # Return the user's balance for the '!aec' reward
      return reward['default_image']['url'], reward['max_per_stream_user'] - reward['user_input_count']
    else
      # The user hasn't redeemed the '!aec' reward yet
      return nil
    end
  end

  def fetch_stream_details(channel_name)
    # Set up the API request URL
    url = URI("https://api.twitch.tv/helix/streams?user_login=#{channel_name}")

    # Set up the headers with the required Authorization header
    headers = {
      'Client-ID' => 'your_client_id',
      'Authorization' => "Bearer #{your_access_token}"
    }

    # Make the request to the Twitch API
    response = Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(url)
      headers.each do |key, value|
        request[key] = value
      end
      http.request(request)
    end

    # Parse the response JSON and return the stream details
    response_json = JSON.parse(response.body)
    stream_details = response_json['data'][0]
    return stream_details
  end

  def total_reviews
    Review.where(reviewee_id: self.id).count
  end

  def verified?
  
    return true if self.rsi_verify == true
    end
    
end
