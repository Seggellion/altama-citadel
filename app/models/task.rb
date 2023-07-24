class Task < ApplicationRecord
    belongs_to :task_manager

    def getModalId
        task = self
        @window_states =  []
        window_state_csv = task.state
        @attribute = ""
        unless window_state_csv.nil?
          @window_states = window_state_csv.split(',')
          @modal_types = window_state_csv.split('|')
        end  
        if @modal_types[1] && @modal_types[1].include?('department')
            get_id = @modal_types[0].gsub(/[^0-9]/, '').to_i
            @attribute= get_id
        end
        @attribute
    end
    
    def sub_windows

    end


    def getModalAttribute(window)
        task = self
        @window_states =  []
        @modal_types = []
        window_state_csv = task.state
        @attribute = ""
        unless window_state_csv.nil?
          @window_states = window_state_csv.split(',')
          @modal_types = window_state_csv.split('|')
        end  
        if @modal_types[1] && @modal_types[1].include?('department')
            get_id = @modal_types[0].gsub(/[^0-9]/, '').to_i
            @attribute="modal-#{get_id}|department" 
        elsif @modal_types[0] && @modal_types[0].include?('allposition')                    
            @attribute = "modal-allposition"
        end

        @attribute
    end
    def mail(user)
        Message.where(task_name: self.name, user_id: user.id)
    end

    def getModalType
        task = self
        
        @window_states =  []
        window_state_csv = task.state
        @attribute = ""
        unless window_state_csv.nil?
          @window_states = window_state_csv.split(',')
          @modal_types = window_state_csv.split('|')
          @attribute =  @modal_types[1]
        end  
        if @attribute
            @attribute.gsub(/.*?(?:[.?!]\s+|\z)/, &:capitalize)
        else
            "Allposition"
        end

    end

    def self.any_memos(user)
        @task_manager = TaskManager.find_by(user_id: user)
        if @task_manager
            
        @all_tasks = Task.where(task_manager_id: @task_manager.id)
        @memos = @all_tasks.where.not(memo_type: [nil, ""])
        
        if @memos.empty?
            return false
        else
            return true
        end
    else
        return false
    end

    end

    
    def memo(data)
        task = Task.find_by_id(self.id)
        
        task.update(memo_type: data[:memo_type], memo_text: data[:memo_text])
    end


    def sub_windows
        if  self.state
       self.state.split(',')
        else
             []
        end
    end

    
    def getModalTitle
        task = self
        @window_states =  []
        @modal_types = []
        window_state_csv = task.state
        @attribute = ""
        
        unless window_state_csv.nil?
          @window_states = window_state_csv.split(',')
          @modal_types = window_state_csv.split('|')
        end  
        if @modal_types[1] && @modal_types[1].include?('department')
            get_id = @modal_types[0].gsub(/[^0-9]/, '').to_i            
            @title = Department.find_by_id(get_id).title
        end
        if @window_states[0].include?('allposition')                    
            @title = "All positions"
        end
        @title.gsub(/.*?(?:[.?!]\s+|\z)/, &:capitalize)
    end

    def response
    self.state
    end


end
