class Moonstone 
    def compile(file_contents)
        
        @task =  Task.new(name: 'Moonstone',task_manager_id: task_manager.id, view: 'window')
        respond_to do |format|
          if @task.save
            format.html { redirect_to desktop_path }
            #format.html { redirect_to desktop_path, notice: "Task started." }
            format.json { render :index, status: :created, task: @task }
          else
            format.html { render :index, status: :unprocessable_entity }
            format.json { render json: @task.errors, status: :unprocessable_entity }
          end
        end
    end
end
