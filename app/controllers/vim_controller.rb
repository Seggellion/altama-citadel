class VimController < ApplicationController

    def vim_command
    command = params[:query][1]
    @task_manager = TaskManager.find_by(user_id: current_user)
    @all_tasks = Task.where(task_manager_id: @task_manager.id)
    @task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Altama Shell")
    filename = params[:query][3..-1]
    
    case command
      
        when "q"

            @task.update(state:'exit')
        when "w"
            # use colon w to save file. colon w space filename to name. then you must colon q to quit
            unless filename
              filename = "untitled"                   
            end
            #...
            out_file = File.new("app/views/desktop/apps/shell_apps/files/#{filename}.moo", "w")
            out_file.puts(params[:text_content])
            #...


          # File.open("out.txt", "w") do |f|     
            #    f.write(data_you_want_to_write)   
          #    end


            out_file.close
           # @task.update(state:'exit')
        when "wq"
          filename = params[:query][4..-1]
            unless filename
              filename = "untitled"                   
            end
            #...
            out_file = File.new("app/views/desktop/apps/shell_apps/files/#{filename}.moo", "w")
            out_file.puts(params[:text_content])
            #...



            out_file.close
            # @task.update(state:'exit')  
            @task.update(state:'exit')         
           
      end
    
    redirect_to root_path
    end
    
    end
    