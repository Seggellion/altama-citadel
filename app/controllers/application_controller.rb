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

def vote
binding.break
end

end
