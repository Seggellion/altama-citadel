class WindowsController < ApplicationController
    before_action :task_manager

    def maximize

    end

    def minimize

    end

    def close
        active_task = Task.where(task_manager_id: @current_user.task_manager.id)
        .find_by(name: params[:window])

        unless active_task
        active_task = Task.where(task_manager_id: @current_user.task_manager.id)
                    .find_by(state: params[:window])
        end

        active_task&.destroy
        redirect_to root_path

    end

end