class WindowsController < ApplicationController
    before_action :task_manager

    def maximize

    end

    def minimize

    end

def close
  window_param = params[:window]

  # 1. Attempt to find the task by name OR by matching state
  active_task = @all_tasks.find_by(name: window_param) || 
                @all_tasks.where("state ILIKE ?", "%#{window_param}%").first

  # 2. GUARD CLAUSE: If active_task is nil, redirect and stop execution immediately
  if active_task.nil?
    redirect_to root_path
    return
  end

  # 3. Logic to remove the window from the state string
  # Safe navigation (.to_s) ensures split works even if state is nil
  windows = active_task.state.to_s.split(',') 

  if windows.include?(window_param)
    windows = windows - [window_param]
  end

  # 4. Decide whether to Update or Destroy
  if windows.empty?
    # If there are no windows left in the state, destroy the task
    active_task.destroy
  else
    # Otherwise, update the task with the new comma-separated string
    active_task.update(state: windows.join(','))
  end

  redirect_to root_path
end


end