class WindowsController < ApplicationController
    before_action :task_manager

    def maximize

    end

    def minimize

    end

    def close
        active_task = @all_tasks.find_by(name: params[:window])

        unless active_task
        active_task = @all_tasks.find_by(state: params[:window])                                    
        windows = active_task.state.split(',')

        if windows.include?(params[:window])    
            windows = windows - Array(params[:window])
        end

        states_string = windows.join(',')

        active_task.update(state:states_string)



        else
            active_task&.destroy
        end
        
        redirect_to root_path

    end

end