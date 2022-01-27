class WelcomeController < ApplicationController
# before_action :authenticate_user!
before_action :not_logged_in

def index
@current_user = current_user
# Discord::Notifier.message('Discord Notifier Webhook Notification')
end



private

def not_logged_in
  if current_user
    redirect_to desktop_path
  end
end


end
