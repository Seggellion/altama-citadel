# Operator review of Tiltify donations: manual Twitch assignment and confirmation of missing donations' status.
# Every change is audited and immediately re-materialises donor tickets for undrawn giveaways only.
class ExtraLifeDonationsController < ApplicationController
  include ExtraLifeEventAccess

  before_action :require_signed_in
  before_action :set_bot_and_event
  before_action :require_event_operator
  before_action :set_donation

  # Step 1: resolve the typed login and show the canonical account before anything is saved.
  def assign
    @login = params[:login].to_s.strip
    @account = TwitchUserLookup.by_login(@login) if @login.present?
    @not_found = @login.present? && @account.nil?
  rescue TwitchUserLookup::Error => e
    @lookup_error = e.message
  end

  # Step 2: persist. The account is re-resolved by id server-side; nothing the browser sends is trusted as identity.
  def confirm_assign
    reason = params[:reason].to_s.strip
    return back_with("A reason is required.") if reason.blank?

    begin
      account = TwitchUserLookup.by_id(params[:twitch_user_id])
    rescue TwitchUserLookup::Error => e
      return back_with("Twitch could not verify the account (#{e.message}). Nothing was changed.")
    end
    return back_with("That Twitch account does not exist. Nothing was changed.") if account.nil?
    return back_with("The broadcaster cannot receive donor tickets.") if account.id == @event.broadcaster_twitch_id

    ActiveRecord::Base.transaction do
      ta = TwitchAccount.find_or_initialize_by(twitch_user_id: account.id)
      ta.update!(login: account.login, display_name: account.display_name, last_resolved_at: Time.current)
      before = @donation.resolved_twitch_user_id
      @donation.lock!
      @donation.update!(manual_twitch_user_id: account.id, resolved_twitch_user_id: account.id,
                        manual_assigned_by_user_id: current_user.id, manual_assigned_at: Time.current,
                        manual_reason: reason, revision: @donation.revision + 1)
      DonationAuditEvent.create!(external_donation: @donation, event_type: "manual_assigned", actor_user_id: current_user.id,
                                 reason: reason, details: { from: before, to: account.id, auto: @donation.auto_twitch_user_id })
      @event.refresh_donor_sources!
    end
    redirect_to event_path_for, notice: "Donation assigned to #{account.login} (#{account.id}). Undrawn giveaways updated; drawn ones are unchanged.", status: :see_other
  end

  def clear_assignment
    reason = params[:reason].to_s.strip
    return back_with("A reason is required.") if reason.blank?
    return back_with("This donation has no manual assignment.") unless @donation.manual?

    ActiveRecord::Base.transaction do
      @donation.lock!
      before = @donation.manual_twitch_user_id
      @donation.update!(manual_twitch_user_id: nil, resolved_twitch_user_id: @donation.auto_twitch_user_id,
                        manual_assigned_by_user_id: nil, manual_assigned_at: nil, manual_reason: nil,
                        revision: @donation.revision + 1)
      DonationAuditEvent.create!(external_donation: @donation, event_type: "manual_cleared", actor_user_id: current_user.id,
                                 reason: reason, details: { from: before, to: @donation.auto_twitch_user_id })
      @event.refresh_donor_sources!
    end
    redirect_to event_path_for, notice: "Manual assignment removed.", status: :see_other
  end

  # Owner decision 2026-11-04: an operator may confirm a missing donation as refunded or still completed after checking
  # the Tiltify dashboard. This is the verification that unblocks draws.
  def confirm_status
    status = params[:status].to_s
    return back_with("Choose refunded or completed.") unless %w[refunded completed].include?(status)
    return back_with("Only donations marked missing need status confirmation.") unless @donation.provider_status == "missing"

    ActiveRecord::Base.transaction do
      @donation.lock!
      @donation.update!(provider_status: status, status_source: "operator_confirmed", status_confirmed_by_user_id: current_user.id,
                        status_confirmed_at: Time.current, status_note: params[:note].to_s.strip.presence,
                        revision: @donation.revision + 1)
      DonationAuditEvent.create!(external_donation: @donation, event_type: "status_confirmed", actor_user_id: current_user.id,
                                 reason: params[:note].to_s.strip.presence, details: { from: "missing", to: status })
      @event.refresh_donor_sources!
    end
    redirect_to event_path_for, notice: "Donation confirmed as #{status} in Tiltify.", status: :see_other
  end

  private

  def set_donation
    @donation = ExternalDonation.for_event(@event).find(params[:id])
  end

  def back_with(message)
    redirect_to event_path_for, alert: message, status: :see_other
  end
end
