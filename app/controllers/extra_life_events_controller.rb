class ExtraLifeEventsController < ApplicationController
  include ExtraLifeEventAccess

  before_action :require_signed_in
  before_action :set_bot, only: :create
  before_action :set_bot_and_event, except: :create
  before_action :require_admin, only: %i[create update]
  before_action :require_event_operator, only: %i[show request_sync]

  def show
    @giveaways = @event.giveaways.order(:id)
    @donations = ExternalDonation.for_event(@event).includes(:resolved_account, :manual_assigned_by, :status_confirmed_by)
                                 .order(Arel.sql("completed_at DESC NULLS LAST, id DESC"))
    @review = @donations.select(&:review_needed?)
    @runs = @event.sync_runs.order(id: :desc).limit(5)
    @attempts = @event.draw_attempts.includes(:giveaway, :winner_account).order(id: :desc)
  end

  def create
    @event = @bot.extra_life_events.new(bot: @bot)
    if assign_attributes_and_save(@event)
      redirect_to event_path_for, notice: "Extra Life event created. Attach giveaways with mode 'Extra Life + Tiltify event'.", status: :see_other
    else
      redirect_to root_path, alert: "Event not created: #{@event.errors.full_messages.to_sentence}", status: :see_other
    end
  end

  def update
    if assign_attributes_and_save(@event)
      redirect_to event_path_for, notice: "Event updated.", status: :see_other
    else
      redirect_to event_path_for, alert: "Event not updated: #{@event.errors.full_messages.to_sentence}", status: :see_other
    end
  end

  def request_sync
    @event.update_columns(sync_requested_at: Time.current, updated_at: Time.current)
    redirect_to event_path_for, notice: "Sync requested; the bot picks it up within about 10 seconds.", status: :see_other
  end

  private

  def set_bot
    @bot = Bot.find(params[:bot_id])
  end

  def event_params
    params.require(:extra_life_event).permit(:name, :broadcaster_login, :tiltify_campaign_url, :tiltify_campaign_id,
                                             :stream_start_local, :time_zone, :enabled)
  end

  def assign_attributes_and_save(event)
    p = event_params
    event.assign_attributes(p.slice(:name, :tiltify_campaign_url, :time_zone, :enabled))
    event.tiltify_campaign_id = p[:tiltify_campaign_id].to_s.strip.downcase.presence if p.key?(:tiltify_campaign_id)
    if p[:stream_start_local].present?
      zone = ActiveSupport::TimeZone[event.time_zone.presence || "America/Vancouver"]
      parsed = zone&.parse(p[:stream_start_local])
      if parsed.nil?
        event.errors.add(:stream_start_at, "is not a valid date/time")
        return false
      end
      event.stream_start_at = parsed.utc
    end
    login = p[:broadcaster_login].to_s.strip.downcase
    if login.present? && (event.new_record? || login != event.broadcaster_login)
      begin
        user = TwitchUserLookup.by_login(login)
      rescue TwitchUserLookup::Error => e
        event.errors.add(:broadcaster_login, "could not be verified with Twitch (#{e.message}); try again")
        return false
      end
      if user.nil?
        event.errors.add(:broadcaster_login, "is not a Twitch account")
        return false
      end
      event.broadcaster_twitch_id = user.id
      event.broadcaster_login = user.login
    end
    event.save
  end
end
