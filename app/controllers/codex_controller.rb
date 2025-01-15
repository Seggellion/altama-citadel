class CodexController < ApplicationController
  # before_action :require_login, except: [:find_article]  
  before_action :task_manager, except: [:invite, :invite_task, :event_join, :verify_username] 
  #before_action :authenticate_user!, only: [:invite]


  API_BASE = 'https://api.gallog.co/v1/commodities'.freeze
  include CommodityConstants

  def populate_commodity    
    commodities.each do |commodity|
      commodity_data = commodity_data_for(commodity)
      
      handle_locations(commodity, commodity_data['data']['buyLocations'])
      handle_locations(commodity, commodity_data['data']['sellLocations'])
    end
    redirect_to root_path
  end

  ## stuff for link invite

  def invite
    session[:event_id_for_signup] = params[:id]
    if user_signed_in?

    @task = invite_task
    

    @event_user = EventUser.new


    @event = Event.find(session[:event_id_for_signup] || params[:id])

    @eligible_ships = Ship.all.select { |ship| ship.code == @event.keyword_required }
    # You can initialize more variables here if needed
  else
    render 'auto_redirect_to_discord' and return
  end
  end

# In your controller or helper method
def invite_task
  Task.new(
    name: "Event Invite",
    author: "N/A",
    icon: "default_icon.png",
    task_manager_id: nil, # or some default value
    state: "temporary",
    view: "default_view",
    memo_type: "N/A",
    memo_text: "This is a temporary task."
    # You don't need to set id, created_at, or updated_at as they are handled automatically
  )
end


def event_join
  
  params[:event_user][:user_id] = current_user.id
  update_rsi_username_if_blank
  ship_id = params[:ship_id]
  ship_name = params[:event_user][:ship_name]
  usership = find_or_create_usership_for_current_user(ship_id, ship_name)


  current_event = Event.find_by_id(event_user_params[:event_id])
  event_series = EventSeries.find_by_id(current_event.event_series_id)
  
  if current_event.event_series_id && event_series&.must_join_all
    Event.where(event_series_id: current_event.event_series_id).each do |event|
      event_user = create_event_user(usership, event)
      create_event_ship(event_user, usership, event)
      update_user_stats
    end
  else
    event_user = create_event_user(usership, current_event)
    create_event_ship(event_user, usership, current_event)
    update_user_stats
  end
  TaskManager.find_or_create_by(user_id: @current_user.id)
  redirect_to desktop_path, notice: "Event Joined"
end




  

  def verify_username
    rsi_username = params[:rsi_username]

    @username_exists = verify_rsi_username_exists(rsi_username) # Implement this method
  
    respond_to do |format|
    #  format.turbo_stream {
    #    render turbo_stream: turbo_stream.replace("username_verification_result", partial: "codex/verify_username")
    #  }

    format.turbo_stream do
      render turbo_stream: turbo_stream.append("username_verification_result", partial: "codex/verify_username")
    end

    format.html { redirect_to action: :index, notice: "Verified username." }
    format.turbo_stream
   #format.turbo_stream
    #format.html { render plain: "HTML format not supported for this action" }
    end
  end
  
  def verify_rsi_username_exists(username)
    url = URI.parse("https://robertsspaceindustries.com/citizens/#{username}")
    request = Net::HTTP.new(url.host, url.port)
    request.use_ssl = (url.scheme == "https")
    response = request.request_head(url.path)
  
    # If the response is 200 OK, the user exists
    response.code == '200'
  rescue StandardError
    # Handle any exceptions, possibly log them, and return false
    false
  end
    # end of stuff for invite link feature

    def close_codex_window
        task = @all_tasks.find_by(name: "Codex" )        
        task.update(state:'')
        redirect_to root_path
    end

    def close_find_window
      task = @all_tasks.find_by(name: "Codex" )
      existing_state = task.state
      split_state = existing_state.split('|')
       split_state.delete("find")
      states_string =  split_state.join('|')
      task.update(state:states_string)      
      redirect_to root_path
  end

    def article
      @window_states =  []
      
      unless @all_tasks.find_by(name: "Codex" ).present?
        @window_states = @window_states + Array[state_name]
      end

      task = @all_tasks.find_by(name: "Codex" )
      window_state_csv = task.state
        if Article.first
          random_article = Article.order("RANDOM()").first
          state_name = "article|" + random_article.id.to_s
        else
          state_name = "article|"
        end

      
      unless window_state_csv.nil?
        @window_states = window_state_csv.split(',')
        message_states = window_state_csv.split('|')
      end  
      
      unless @window_states.include?(state_name)
          @window_states = @window_states + Array[state_name]
      end
      states_string = @window_states.join(',')
      
      task.update(state:states_string)
      redirect_to root_path
    end

    def show_article
    
  
      task = @all_tasks.find_by(name: "Codex" )
      article_id = params[:id]
      state_name = "article|" + article_id
  
      task.update(state:state_name)
      redirect_to root_path
    end


    def back_article
    
      task = @all_tasks.find_by(name: "Codex" )
      state_name = "article|" 
      task.update(state:state_name)
      redirect_to root_path
    end

    def find_article
      
      task = @all_tasks.find_by(name: "Codex" )
      existing_state = task.state
      split_state = existing_state.split('|')
      #added_state = Array["find"]
     # new_state = split_state + added_state
     unless split_state.include?("find")      
      new_state = split_state.insert(1,"find")
      states_string = new_state.join('|')

      task.update(state:states_string)
      
     end


      
      #state_name = "article|" 

      puts task.state
      puts "----------------"

      respond_to do |format|
        format.html { redirect_to root_path }
      end
      
    end

def create_dossier
  @all_tasks.update_all(view: '')
Task.create(task_manager_id: @task_manager.id, name: "Codex", state: "article|makedossier", view:'fullscreen')


     redirect_to root_path

end

def edit_article
  task = @all_tasks.find_by(name: "Codex" )
    article_id = params[:id]
   
     state_name = "article|edit#" + article_id
     task.update(state:state_name)
     redirect_to root_path
end



def populate_locations
  url = 'https://api.gallog.co/v1/tradeports'
  response = URI.open(url).read
  json = JSON.parse(response)
  json["data"]["tradeports"].each do |key, value|
    system_name = key["systemName"]
    object_name = key["objectName"]
    location_name = key["name"]
    unless Location.find_by_name(system_name)
      Location.create(name: system_name,location_type: "star" )
      Article.create(title:system_name, article_type: 'location', user_id: current_user.id, location: system_name)
    end
    unless Location.find_by_name(object_name)
      Location.create(name: object_name,system: system_name, parent: object_name )
      Article.create(title:object_name, article_type: 'location', user_id: current_user.id, location: object_name)
    end
    unless Location.find_by_name(location_name)
      Location.create(name:  location_name, trade_port: true, system: system_name, parent: object_name)
      Article.create(title: location_name, article_type: 'location', user_id: current_user.id, location: location_name)
    end
  end
redirect_to root_path
end

def destroy_all_commodity
  Commodity.destroy_all
  redirect_to root_path
end

def codex_data_processor
  task = @all_tasks.find_by(name: "Codex" )
    
     state_name = "data"
     task.update(state:state_name)
     redirect_to root_path
end

    def create_article

   #   @window_states =  []
    #  unless @all_tasks.find_by(name: "Codex" ).present?
    #    @window_states = @window_states + Array[state_name]
     # end

      task = @all_tasks.find_by(name: "Codex" )
   #   window_state_csv = task.state
      state_name = "article|create"
      
  #    unless window_state_csv.nil?
   #     @window_states = window_state_csv.split(',')
        # codex_states = window_state_csv.split('|')
    #  end  
      
   #   unless @window_states.include?(state_name)
    #      @window_states = @window_states + Array[state_name]
    #  end
    #  states_string = @window_states.join(',')
      
      task.update(state:state_name)
      redirect_to root_path

    end

    def timeline
        @window_states =  []
        unless @all_tasks.find_by(name: "Codex" ).present?
          @window_states = @window_states + Array[state_name]
        end
        
        task = @all_tasks.find_by(name: "Codex" )
        window_state_csv = task.state
        state_name = "timeline"
        
        unless window_state_csv.nil?
          @window_states = window_state_csv.split(',')
          message_states = window_state_csv.split('|')
        end  
        
        unless @window_states.include?(state_name)
            @window_states = @window_states + Array[state_name]
        end
        states_string = @window_states.join(',')
        
        task.update(state:states_string)
        redirect_to root_path
    end


    private

    def commodities
      JSON.parse(URI.open(API_BASE).read)['data']['commodities']
    end
  
    def commodity_data_for(commodity)
      JSON.parse(URI.open("#{API_BASE}/#{commodity['slug']}").read)
    end


  
    def event_user_params
      params.require(:event_user).permit(:rsi_username, :ship_name, :ship_id, :event_id, :user_id)
    end
  
  
    def handle_locations(commodity, locations)
      locations&.each do |location|
        handle_location(commodity, location)
      end
    end
  
    def handle_location(commodity, location)
      if location.nil?
        puts "Error: location is nil for commodity #{commodity['name']}"
        return
      end
      
      sell_price = location['sell'].to_i
      buy_price = location['buy'].to_i
      is_vice = Commodity.is_vice(commodity['name'])

      refresh_per_minute =  REFRESH_PER_MINUTE_MAPPING[commodity['name']] || 50
      max_inventory =  MAX_INVENTORY

      commodity_record = Commodity.find_or_initialize_by(name: commodity['name'], location: location['name'])
      if commodity_record.new_record? || commodity_record.sell != sell_price
        commodity_record.update(
          sell: sell_price,
          buy: buy_price,
          refreshPerMinute: refresh_per_minute,
          maxInventory: max_inventory,
          out_of_date:false,
          active:true,
          vice: is_vice,
          updated_at: location['timestamp']
        )
        create_article_if_not_exists(commodity['name'])
        create_commodity_stub(commodity_record, buy_price, sell_price)
      end
    end

    def commodity_exists?(name, timestamp, location_name, sell_price)
      Commodity.exists?(name: name, updated_at: timestamp, location: location_name, sell: sell_price)
    end
  
    def create_commodity_stub(commodity, buy_price, sell_price)
      CommodityStub.create(
        user_id: 1, 
        buy_price: buy_price, 
        sell_price: sell_price, 
        commodity_id: commodity.id
      )
    end

    def create_article_if_not_exists(title)
      return if Article.find_by_title(title)
  
      Article.create(title: title, article_type: 'commodity', user_id: current_user.id)
    end

    def create_event_user(usership, event)
      EventUser.create!(
        event_series_id: event.event_series_id, 
        usership_id: usership.id, 
        event_id: event.id, 
        user_id: current_user.id, 
        ship_fid: usership.fid
      )
    end
    
    def create_event_ship(event_user, usership, event)
      EventShip.create!(
        event_user_id: event_user.id,
        usership_id: usership.id,
        event_id: event.id,
        ship_fid: usership.fid,
        ship: usership.ship.model,
        ship_name: usership.ship_name
      )
    end
    
    def update_user_stats
      current_user.give_karma(200)
      current_user.give_fame(200)
    end

    def ship_attributes(ship)
      {
        ship_name: ship.alt_ship_name || ship.model,
        ship_image: ship.ship_image_primary,

      }
    end

    def find_or_create_usership_for_current_user(ship_id, ship_name)
     
      ship = Ship.find(ship_id)
      return nil if ship.nil?
    
      Usership.find_or_create_by(user_id: current_user.id,ship_id: ship.id, ship_name: ship_name) do |new_usership|
        new_usership.ship_name = ship.alt_ship_name || ship.model
        new_usership.model = ship.model
        new_usership.ship_id = ship.id
      end
    end

    def update_rsi_username_if_blank
      if current_user.rsi_username.blank?
        current_user.update(rsi_username: params[:event_user][:rsi_username])
      end
    end

end