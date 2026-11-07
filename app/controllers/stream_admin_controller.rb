# Admin actions for the Stream tab in the ALTAMA.EXE window: wallet session, fuelling accidents, OBS overlay link.
# Every action redirects back to the Stream tab with a flash message, because production swallows exceptions
# (ApplicationController#handle_error) and would otherwise show the admin nothing.
class StreamAdminController < ApplicationController
  include GiveawayAdminAuthorization
  include ActiveSupport::NumberHelper

  before_action :require_giveaway_admin
  before_action :set_bot

  def start_session
    balance = StreamWalletSession.parse_balance(params[:balance])
    StreamWalletSession.start!(bot: @bot, balance: balance, user: current_user, idempotency_key: params[:idempotency_key])
    back notice: "Wallet session started at #{auec(balance)}."
  rescue StreamWalletSession::Error => e
    back alert: "Not started: #{e.message}"
  end

  def update_balance
    session = @bot.stream_wallet_sessions.find_by(id: params[:session_id])
    return back(alert: "That wallet session no longer exists. Start a new one.") unless session

    balance = StreamWalletSession.parse_balance(params[:balance])
    result = session.update_balance!(balance: balance, user: current_user, idempotency_key: params[:idempotency_key],
                                     lock_version: params[:lock_version])
    session.reload
    back notice: (result == :duplicate ? "That balance was already saved." : "Balance updated to #{auec(balance)}. Net since Start: #{signed_auec(session.net_auec)}.")
  rescue StreamWalletSession::Error => e
    back alert: "Not updated: #{e.message}"
  end

  def end_session
    session = @bot.stream_wallet_sessions.find_by(id: params[:session_id])
    return back(alert: "That wallet session no longer exists.") unless session

    result = session.end!(user: current_user, lock_version: params[:lock_version])
    back notice: (result == :already_ended ? "That session had already ended." : "Wallet session ended at #{signed_auec(session.reload.net_auec)}.")
  rescue StreamWalletSession::Error => e
    back alert: "Not ended: #{e.message}"
  end

  def record_accident
    FuellingAccident.record_now!(bot: @bot, user: current_user)
    back notice: "Fuelling accident recorded. The counter is back to 0 days."
  end

  def record_historic_accident
    a = FuellingAccident.record_historic!(bot: @bot, user: current_user, date: params[:occurred_on])
    current = FuellingAccident.current_for(@bot.channel)
    note = current&.accident&.id == a.id ? "The counter now shows #{days_text(current.days)}." : "A more recent accident is already on record, so the counter is unchanged."
    back notice: "Accident on #{a.occurred_on.strftime('%b %-d, %Y')} recorded. #{note}"
  rescue FuellingAccident::Error => e
    back alert: "Not recorded: #{e.message}"
  rescue ActiveRecord::RecordInvalid => e
    back alert: "Not recorded: #{e.record.errors.full_messages.to_sentence}"
  end

  def void_accident
    accident = @bot.fuelling_accidents.live.find_by(id: params[:accident_id])
    return back(alert: "That accident is not on record (it may already be undone).") unless accident

    accident.void!(user: current_user)
    current = FuellingAccident.current_for(@bot.channel)
    back notice: "Accident undone. #{current ? "The counter shows #{days_text(current.days)}." : 'No accident is on record now.'}"
  end

  def rotate_overlay
    overlay = StreamOverlay.for_bot(@bot)
    token = overlay.rotate_token!
    flash[:stream_overlay_url] = stream_overlay_url(token: token)
    back notice: "New OBS link created. Any older link has stopped working."
  end

  def update_overlay
    overlay = StreamOverlay.for_bot(@bot)
    if overlay.update(enabled: params[:enabled] == "1", accident_caption: params[:accident_caption].to_s.strip.presence || StreamOverlay::DEFAULT_CAPTION)
      back notice: "Overlay settings saved."
    else
      back alert: "Not saved: #{overlay.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_bot
    @bot = Bot.find(params[:bot_id])
  end

  def back(**flash)
    redirect_to desktop_path(bexe_tab: "stream"), status: :see_other, **flash
  end

  def auec(n) = "#{number_to_delimited(n)} aUEC"

  def signed_auec(n) = n.positive? ? "+#{auec(n)}" : (n.negative? ? "−#{auec(-n)}" : auec(0))

  def days_text(d) = "#{d} day#{'s' unless d == 1}"
end
