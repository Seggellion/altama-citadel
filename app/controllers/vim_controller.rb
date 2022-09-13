class VimController < ApplicationController

    def vim_command
    command = params[:query][1..-1]
    @task_manager = TaskManager.find_by(user_id: current_user)
    @all_tasks = Task.where(task_manager_id: @task_manager.id)
    @task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Altama Shell")

    case command
        when "q"
            @task.update(state:'exit')
        when "w"
            byebug
            
            out_file = File.new("app/views/desktop/apps/shell_apps/files/out.moo", "w")
            #...
            out_file.puts("write your stuff here")
            #...


          # File.open("out.txt", "w") do |f|     
            #    f.write(data_you_want_to_write)   
          #    end


            out_file.close
           # @task.update(state:'exit')
      end
    
    redirect_to root_path
    end
    
    end
    