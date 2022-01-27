class DesktopController < ApplicationController
# before_action :authenticate_user!
before_action :require_login

def index
@current_user = current_user
# Discord::Notifier.message('Discord Notifier Webhook Notification')
end

end
