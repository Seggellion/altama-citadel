class ShellController < ApplicationController

def command_entry
command = params[:query]
@task_manager = TaskManager.find_by(user_id: current_user)
@all_tasks = Task.where(task_manager_id: @task_manager.id)
@task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Altama Shell")


case command
  when "ping?"
    @task.update(state:'Pong!')
  when "clear"
    @task.update(state:'clear')
  when "vim"
    @task.update(state:'vim')
  when "moonstone"
    @task.update(state:'moonstone')
  else
    @task.update(state:'Bad command or file name')
  end

redirect_to root_path
end

end
