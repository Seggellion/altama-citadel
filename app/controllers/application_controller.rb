class ApplicationController < ActionController::Base
    def require_login
        unless current_user
          redirect_to root_url
        end
      end

      def website_require_login
        unless current_user
          redirect_to roadside_assistance_path
        end
      end


      def task_manager

        @current_user = current_user
        @task_manager = TaskManager.find_by(user_id: current_user)
        
        if @task_manager.nil?
          redirect_to bsod_path 
          return
        end
        @all_tasks = Task.where(task_manager_id: @task_manager.id)
        
    end


end
