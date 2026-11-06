class ExtraLifeEventOperatorsController < ApplicationController
  include ExtraLifeEventAccess

  before_action :require_signed_in
  before_action :set_bot_and_event
  before_action :require_admin

  def create
    user = User.find_by("LOWER(username) = ?", params[:username].to_s.strip.downcase)
    if user.nil?
      redirect_to event_path_for(tab: "settings"), alert: "No site user named #{params[:username]}.", status: :see_other
    else
      @event.operators.find_or_create_by!(user: user) { |o| o.granted_by_user_id = current_user.id }
      redirect_to event_path_for(tab: "settings"), notice: "#{user.username} can now operate this event.", status: :see_other
    end
  end

  def destroy
    @event.operators.find(params[:id]).destroy
    redirect_to event_path_for(tab: "settings"), notice: "Operator removed.", status: :see_other
  end
end
