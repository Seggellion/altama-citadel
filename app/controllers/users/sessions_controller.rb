class Users::SessionsController < Devise::SessionsController

    before_action :destroy_task_manager, only: :destroy
  

    def destroy_task_manager
      task_manager = TaskManager.find_by_user_id(current_user.id)
      if task_manager
        task_manager.destroy
      end
    end
  end