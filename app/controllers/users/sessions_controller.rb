class Users::SessionsController < Devise::SessionsController

    before_action :destroy_task_manager, only: :destroy
  
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    end

    def destroy_task_manager
      task_manager = TaskManager.find_by_user_id(current_user.id)
      if task_manager
        task_manager.destroy
      end
    end
  end