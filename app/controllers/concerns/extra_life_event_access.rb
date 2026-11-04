# Event-scoped access: Rails admins (user_type 0) and users explicitly added as operators of that event.
# Twitch moderator status is never consulted. Records are always loaded through bot -> event, so an id from another
# bot or event is a 404, not an action on the wrong event.
module ExtraLifeEventAccess
  extend ActiveSupport::Concern

  private

  # Path-based (the shared require_login redirects to an absolute root_url, which Rails 7 treats as off-host here).
  def require_signed_in
    deny unless current_user
  end

  def set_bot_and_event
    @bot = Bot.find(params[:bot_id])
    @event = @bot.extra_life_events.find(params[:extra_life_event_id] || params[:id])
  end

  def require_event_operator
    deny unless @event.operator?(current_user)
  end

  def require_admin
    deny unless current_user&.isAdmin?
  end

  def deny
    respond_to do |format|
      format.html { redirect_to root_path, alert: "You are not authorized for this Extra Life event.", status: :see_other }
      format.any { head :forbidden }
    end
  end

  def event_path_for(event = @event)
    bot_extra_life_event_path(event.bot_id, event)
  end
end
