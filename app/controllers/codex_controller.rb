class CodexController < ApplicationController
  # before_action :require_login, except: [:find_article]  
  before_action :task_manager
    

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
      @all_tasks = Task.all
  
      task = @all_tasks.find_by(name: "Codex" )
      article_id = params[:id]
      state_name = "article|" + article_id
  
      task.update(state:state_name)
      redirect_to root_path
    end


    def back_article
      @all_tasks = Task.all
      task = @all_tasks.find_by(name: "Codex" )
      state_name = "article|" 
      task.update(state:state_name)
      redirect_to root_path
    end

    def find_article
      @all_tasks = Task.all
      task = @all_tasks.find_by(name: "Codex" )
      existing_state = task.state
      split_state = existing_state.split('|')
      #added_state = Array["find"]
     # new_state = split_state + added_state
     unless split_state.include?("find")      
      new_state = split_state.insert(1,"find")
      states_string = new_state.join('|')
      puts states_string
puts "********"
      task.update(state:states_string)
      byebug
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

def populate_commodity
  url = 'https://api.gallog.co/v1/commodities'
  response = URI.open(url).read
  json = JSON.parse(response)


  json["data"]["commodities"].each do |key, value|
    new_url = 'https://api.gallog.co/v1/commodities/' + key["slug"]
    commodity_response = URI.open(new_url).read
    commodity_json = JSON.parse(commodity_response)
    
    commodity_json["data"]["buyLocations"].each do |location_key, location_value|  
      Commodity.create(name: key["name"], sell: location_key["sell"], buy: location_key["buy"], location: location_key["name"], updated_at: location_key["timestamp"])
        unless Article.find_by_title(key["name"])
          Article.create(title:key["name"], article_type: 'commodity', user_id: current_user.id)
        end
    end
    commodity_json["data"]["sellLocations"].each do |location_key, location_value|  
      Commodity.create(name: key["name"], sell: location_key["sell"], buy: location_key["buy"], location: location_key["name"], updated_at: location_key["timestamp"])
        unless Article.find_by_title(key["name"])
          Article.create(title:key["name"], article_type: 'commodity', user_id: current_user.id)
        end
    end
  end



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



end