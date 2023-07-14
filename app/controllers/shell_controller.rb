class ShellController < ApplicationController
  before_action :task_manager

def  acu_command_entry
  @task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Altama Shell")
  command = params[:query]

  case command
  when "Enter"
    if @task.state == 'acu'
      @task.update(state:'acu|welcome')
    end
  when "4"
    if @task.state == 'acu|welcome'
      @task.update(state:'acu|balance')
    end
  when "m"
    @task.update(state:'acu|welcome')
  when "q"
    @task.update(state:nil)
  end
  redirect_to root_path

end


def traderun_command_entry
  @task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Altama Shell")
  command = params[:format]
  case command
  when "Enter"    
    @task.update(state:'trade123')
  when ->(s) { s.include?('trade_run') }
  @task.update(state:"trade123|#{command}")
  when ->(s) { s.include?('milk_run') }
  @task.update(state:"trade123|#{command}")
  when ->(s) { s.include?('trade_session') }
    @task.update(state:"trade123|#{command}")
  when ->(s) { s.include?('profit') }
    @task.update(state:"trade123|#{command}")
  when ->(s) { s.include?('settings') }
  @task.update(state:"trade123|#{command}")
  when ->(s) { s.include?('streamchart') }
    @task.update(state:"trade123|#{command}")
  when "back"
    @task.update(state:'trade123')
  when "quit"
    @task.update(state:nil)
  end
  redirect_to root_path
end

def command_entry
  
  if params[:query].split.size > 1
    filename = params[:query].split.last
  end
command = params[:query].split.first


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
  when "acu"
    @task.update(state:'acu')
  when "trade123"
    @task.update(state:'trade123')
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
