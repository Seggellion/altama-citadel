class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include PgSearch::Model
  pg_search_scope :search_by_username, against: :username, using: { trigram: { threshold: 0.3 } }
  
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :omniauthable, :jwt_authenticatable,
  omniauth_providers: %i[discord],
  jwt_revocation_strategy: JwtDenylist

  has_many :event_users, dependent: :destroy
  has_many :userships
  has_many :trade_sessions, foreign_key: 'owner_id'
  #has_many :ships, :through => :userships
  has_many :ships, through: :userships, source: :ship, foreign_key: 'model'
  has_many :commodity_stubs
  has_one :task_manager
  has_many :rfas
  has_many :messages
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'
  
  # Associations for StarBitizenRace
  has_many :created_races, class_name: 'StarBitizenRace', foreign_key: 'user_id'
  has_many :star_bitizen_race_users
  has_many :participated_races, through: :star_bitizen_race_users, source: :star_bitizen_race

  # Associations for UserSkill
  has_many :user_skills

  # You can add more font names to this array as per your requirements
  ALLOWED_FONTS = [
    'Arial', 
    'Arial Black', 
    'Comic Sans MS', 
    'Courier New', 
    'Georgia', 
    'Impact', 
    'Times New Roman', 
    'Trebuchet MS', 
    'Verdana', 
    'Webdings', 
    'MS Sans Serif', 
    'MS Serif'
  ]

  validates :font_name, inclusion: { in: ALLOWED_FONTS }
  validates :font_color, :background_color, :accent_color, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, message: "must be a valid hex color" }
  validates :font_size, numericality: { only_integer: true, greater_than_or_equal_to: 8, less_than_or_equal_to: 36 }

  has_many :milk_runs
  has_many :friendships
  has_many :trade_runs, primary_key: 'username', foreign_key: 'username'
  # Associations for the forum
  has_many :forum_posts, dependent: :destroy
  has_many :forum_comments, dependent: :destroy
  has_one :position, :through => :user_position
  has_one :user_position
  has_many :sent_transactions, class_name: 'Transaction', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_transactions, class_name: 'Transaction', foreign_key: 'receiver_id', dependent: :destroy
  validates :username, uniqueness: { case_sensitive: false }

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

def total_star_bitizen_runs

  StarBitizenRun.where(twitch_channel:self.twitch_id).count

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

def session_profit(trade_session)
  trade_runs = TradeRun.where(username: self.username, trade_session_id: trade_session.id)
  milk_runs = MilkRun.where(user_id: self.id, trade_session_id: trade_session.id)
  total_profit = (trade_runs.sum(:profit) + milk_runs.sum(:profit))
  
  total_profit
  formatted_profit = total_profit.to_s(:delimited)
  formatted_profit
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


    def reputation
    
      case self.fame
      when 0..1249
          fame_level = 1
      when 1250..2499
          fame_level = 2
      when 2500..4999
          fame_level = 3
      when 5000..9999
          fame_level = 4
      when 10000..32000
          fame_level = 5
      end
  
      case self.karma
      when 10000..32000
          karma_level = 1
      when 5000..9999
          karma_level = 2
      when 2500..4999
          karma_level = 3
      when 1250..2499
          karma_level = 4
      when 625..1249
          karma_level = 5
      when -625..624
          karma_level = 6
      when -1249..-625
          karma_level = 7
      when -2499..-1250
          karma_level = 8
      when -4999..-2500
          karma_level = 9
      when -9999..-5000
          karma_level = 10
      when -32000..-10000
          karma_level = 11
      end
  
      title_matrix = [
          ['Trustworthy', 'Estimable', 'Great', 'Glorious', 'Glorious Lord/Lady'],
          ['Honest', 'Commendable', 'Famed', 'Illustrious', 'Illustrious Lord/Lady'],
          ['Good', 'Honorable', 'Admirable', 'Noble', 'Noble Lord/Lady'],
          ['Kind', 'Respectable', 'Proper', 'Eminent', 'Eminent Lord/Lady'],
          ['Fair', 'Upstanding', 'Reputable', 'Distinguished', 'Distinguished Lord/Lady'],
          [nil, 'Notable', 'Prominent', 'Renowned', 'Lord/Lady'],
          ['Rude', 'Disreputable', 'Notorious', 'Infamous', 'Dishonored Lord/Lady'],
          ['Unsavory', 'Dishonorable', 'Ignoble', 'Sinister', 'Sinister Lord/Lady'],
          ['Scoundrel', 'Malicious', 'Vile', 'Villainous', 'Dark Lord/Lady'],
          ['Despicable', 'Dastardly', 'Wicked', 'Evil', 'Evil Lord/Lady'],
          ['Outcast', 'Wretched', 'Nefarious', 'Dread', 'Dread Lord/Lady']
      ]
  
      title = title_matrix[karma_level - 1][fame_level - 1]

      "The #{title}" if title.present?
    
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
    all_ships = Usership.where(user_id: self.id, model: ship.model)
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
    uid = auth.uid
    provider = auth.provider
    global_name = auth.extra.raw_info["global_name"]
    username = auth.extra.raw_info["username"]
    profile_image = auth.info.image
  
    # Find user by UID and provider
    user = where(provider: provider, uid: uid).first
  
    # Attempt to find a matching user by partial username for other providers
    matching_user = where.not(provider: provider)
                       .where("username ILIKE ?", "#{username.split(/[0-9]+/).first}%")
                       .first
  
    if matching_user
      # Merge current provider's data into the matched user
      matching_user.update(
        provider: provider, # Update to the current provider
        uid: uid,
        profile_image: profile_image.presence || matching_user.profile_image,
        username: global_name.presence || matching_user.username,
        aec: matching_user.aec + (user&.aec || 0),
        fame: matching_user.fame + (user&.fame || 0), # Add fame from the previous user
        karma: matching_user.karma + (user&.karma || 0), # Add karma from the previous user
        last_login: Time.current
      )
  
      # Transfer related records to the matched user
      transfer_related_records(user&.id, matching_user.id) if user
  
      # Delete the previous user after merging
      user.destroy if user
  
      return matching_user
    end
  
    # If no matching user, use or create a user for the current provider
    if user
      # Update existing user attributes
      user.update(
        username: global_name.presence || user.username,
        profile_image: profile_image.presence || user.profile_image,
        last_login: Time.current
      )
      user
    else
      # Create a new user
      create(
        provider: provider,
        uid: uid,
        username: global_name || username,
        profile_image: profile_image,
        password: Devise.friendly_token[0, 20],
        user_type: params["plus"] == "true" ? 100 : 101,
        fame: 0,
        karma: 0
      )
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
    Message.where(user_id: self.id)#.order(created_at: :DESC)
  end

  def my_messages_sorted
    Message.where(user_id: self.id).order(created_at: :DESC)
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

  def system_messages
    self.messages.where(subject:"system")
  end

  def has_unread_messages_from?(friend)
    # Logic here to identify if there are unread messages
  end

  def friend_requests
    self.messages.where(subject:"Friend Request")
  end

  def filtered_by_receiver(receiver)
    my_messages = self.messages.where(receiver_id: receiver)
    receiver_messages = Message.where(user_id: receiver, receiver_id: self.id)
    messages = (my_messages + receiver_messages).sort_by(&:created_at)
    messages
  end

  def status_image_path
    status = online_status || "offline"
    "asl_status_#{status.downcase.gsub(' ', '_')}.png"
  end

  def total_reviews
    Review.where(reviewee_id: self.id).count
  end

  def verified?
  
    return true if self.rsi_verify == true
    end
    
    private 
    def self.transfer_related_records(old_user_id, new_user_id)
      # Example: Update foreign keys in related records
      Usership.where(user_id: old_user_id).update_all(user_id: new_user_id)
    end

end
