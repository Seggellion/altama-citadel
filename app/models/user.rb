class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :omniauthable, omniauth_providers: %i[discord]
  has_many :userships
  has_many :ships, :through => :userships
  has_one :task_manager
  has_many :rfas

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
  self.update(last_login: Date.today)
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
      discord_user = DiscordUser.find_by(username: self.username).role
    end

   def user_type_text
    if self.user_type == 0
      p 'Administrator'
    elsif self.user_type == 10
      p 'Members of the Board'
    elsif self.user_type == 15
      p 'Executive'
    elsif self.user_type == 20
      p 'Partner'
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
    if self.user_type != 42
      return true
    end
  end

 

  def isPlus?
    if self.user_type == 1202
      return true
    end
  end

def ship_count(ship)
  all_ships = Usership.where(user_id: self.id, ship_id: ship.id)
  all_ships.count
end


    def self.from_omniauth(auth, params)
      
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      if params["plus"] == "true"
        user.user_type = 1202 
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
  
  def verified?
  
    return true if self.rsi_verify == true
    end
    
end
