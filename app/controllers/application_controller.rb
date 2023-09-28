class ApplicationController < ActionController::Base
   rescue_from StandardError, with: :handle_error if Rails.env.production?


 # before_action :set_user_session

# default devise stuff from chatgpt

 # before_action :authenticate_user!

 helper_method :current_user, :user_signed_in?
 
 def current_user  
  
   @current_user ||= User.find_by(username: session[:username]) if session[:username]
 end
 
 def user_signed_in?
   current_user.present?
 end

 ## end default devise stuff

  #error handler
  def fetch_log_data
    log_file_path = Rails.root.join('log', "#{Rails.env}.log")
    `tail -n 50 #{log_file_path}`
  end

  def handle_error(e)
    @log_data = fetch_log_data if Rails.env.production?
    #render 'error', status: :internal_server_error
    #disabled bsod
    # render 'bsod', status: :internal_server_error
    #redirect_to bsod_path 
    #code to send email and redirect to error page
  end


  def require_login
    
    Rails.logger.debug "Current User: #{current_user.inspect}"
    unless current_user
      
      Rails.logger.debug "No current user, redirecting to root_url"
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

    private

    def set_user_session
      if current_user
        
        session[:username] = current_user.username
      end
    end
end
