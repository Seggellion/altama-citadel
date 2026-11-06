# Audited cancellation of an unfinalized (blocked) draw. Finalized draws cannot be changed.
class ExtraLifeDrawAttemptsController < ApplicationController
  include ExtraLifeEventAccess

  before_action :require_signed_in
  before_action :set_bot_and_event
  before_action :require_event_operator

  def cancel
    reason = params[:reason].to_s.strip
    attempt = @event.draw_attempts.find(params[:id])
    if reason.blank?
      return redirect_to(event_path_for, alert: "A reason is required to cancel a draw.", status: :see_other)
    end

    cancelled = false
    ActiveRecord::Base.transaction do
      attempt.giveaway.lock!
      attempt.lock!
      next unless attempt.status == "pending"

      attempt.update!(status: "cancelled", cancelled_at: Time.current, cancelled_by_user_id: current_user.id, cancel_reason: reason)
      attempt.giveaway.update_columns(entry_state: "open", updated_at: Time.current)
      @event.refresh_donor_sources!
      cancelled = true
    end
    if cancelled
      redirect_to event_path_for, notice: "Draw cancelled. Chat entries for !#{attempt.giveaway.command_name} are open again; the next !drawing sets a new cutoff.", status: :see_other
    else
      redirect_to event_path_for, alert: "Only a pending (not finalized) draw can be cancelled.", status: :see_other
    end
  end
end
