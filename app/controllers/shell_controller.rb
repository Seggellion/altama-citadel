class ShellController < ApplicationController

def command_entry
  
  if params[:query].split.size > 1
    filename = params[:query].split.last
  end
command = params[:query].split.first

@task_manager = TaskManager.find_by(user_id: current_user)
@all_tasks = Task.where(task_manager_id: @task_manager.id)
@task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Altama Shell")


case command
  when "ls"
    
  # directory = Dir["app/views/desktop/apps/shell_apps/files/*"].select { |f| File.file? File.join("your/folder", f) }
  #directory = Dir.glob('app/views/desktop/apps/shell_apps/files/*').select { |e| File.file? e }
  directory = Dir[ 'app/views/desktop/apps/shell_apps/files/*' ].select{ |f| File.file? f }.map{ |f| File.basename f }

   @task.update(state:directory.prepend("LS"))
  when "ping?"
    @task.update(state:'Pong!')
  when "clear"
    @task.update(state:'clear')
  when "vim"    
    @task.update(state:'vim')
  when "moonstone"  
    
    if filename    
      file_content = File.read("app/views/desktop/apps/shell_apps/files/#{filename}")
      Moonstone.compile(file_content)
    else
      text = "No file specified"
    end
    @task.update(state:text)
  when "exit"
    @task.destroy    
  else
    @task.update(state:'Bad command or file name')
  end

redirect_to root_path
end

end
