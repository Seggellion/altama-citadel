class ApplicationController < ActionController::Base
    def require_login
        unless current_user
          redirect_to root_url
        end
      end
end
