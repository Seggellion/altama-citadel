class CodexController < ApplicationController
  # before_action :require_login, except: [:find_article]  
  before_action :task_manager

  API_BASE = 'https://api.gallog.co/v1/commodities'.freeze

  def populate_commodity    
    commodities.each do |commodity|
      commodity_data = commodity_data_for(commodity)
      
      handle_locations(commodity, commodity_data['data']['buyLocations'])
      handle_locations(commodity, commodity_data['data']['sellLocations'])
    end
    redirect_to root_path
  end


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
    
      commodity_record = Commodity.find_or_initialize_by(name: commodity['name'], location: location['name'])
      if commodity_record.new_record? || commodity_record.sell != sell_price
        commodity_record.update(
          sell: sell_price,
          buy: buy_price,
          refreshPerMinute: location['refreshPerMinute'],
          maxInventory: location['maxInventory'],
          out_of_date:false,
          vice: is_vice
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

end