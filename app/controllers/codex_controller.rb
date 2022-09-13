class CodexController < ApplicationController
    before_action :task_manager

    def close_window

        task = @all_tasks.find_by(name: "Codex" )
      
 
        
        task.update(state:'')
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