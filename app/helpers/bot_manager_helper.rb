# Presentation helpers for the ALTAMA.EXE Bot Manager window and the Extra Life event window.
module BotManagerHelper
  MODE_LABELS = {
    "single" => "Single entry",
    "multiple" => "Multiple entries",
    "multiple-extra-life" => "Extra Life (legacy bonus)",
    "extra-life" => "Extra Life (legacy)",
    "extra-life-tiltify" => "Extra Life + Tiltify"
  }.freeze

  def giveaway_mode_label(mode)
    MODE_LABELS.fetch(mode.to_s, mode.to_s)
  end

  # A giveaway is closed once it has a winner, or (event mode) once its draw is finalized, even with no winner.
  def giveaway_closed?(giveaway)
    giveaway.winner.present? || giveaway.entry_state == "finalized"
  end

  # [label, css class] for the status badge.
  def giveaway_status(giveaway)
    return ["Drawn", "drawn"] if giveaway.winner.present?
    return ["Closed (no eligible entries)", "drawn"] if giveaway.entry_state == "finalized"
    return ["Draw pending", "pending"] if giveaway.entry_state == "frozen"

    ["Open", "open"]
  end

  # Entrants: distinct Twitch accounts holding an active ticket (event mode) or legacy join rows.
  def giveaway_entry_count(giveaway)
    if giveaway.event_mode?
      giveaway.ticket_sources.where(active: true).distinct.count(:twitch_user_id)
    else
      giveaway.giveaway_users.size
    end
  end

  def event_time(event, time, format = "%a %b %-d, %-I:%M %p %Z")
    time&.in_time_zone(event.time_zone.presence || "America/Vancouver")&.strftime(format)
  end

  # Readiness checks shown on the event overview, in the order an operator fixes them.
  # Each item: [state (:ok, :no, :wait), label, detail].
  def extra_life_readiness(event, giveaways)
    items = []
    items << [event.broadcaster_twitch_id.present? ? :ok : :no, "Broadcaster verified with Twitch",
              "#{event.broadcaster_login} (id #{event.broadcaster_twitch_id || '?'}) — never eligible to win"]
    items << [event.stream_start_at ? :ok : :no, "Stream start set",
              event.stream_start_at ? "Donations count from #{event_time(event, event.stream_start_at)}" : "Set it in Settings"]
    campaign_state = if event.tiltify_campaign_id.present? then :ok
                     elsif event.tiltify_campaign_url.present? then :wait
                     else :no
                     end
    items << [campaign_state, "Tiltify campaign resolved",
              case campaign_state
              when :ok then "Campaign #{event.tiltify_campaign_id}"
              when :wait then "Waiting for the bot to resolve #{event.tiltify_campaign_url} (about a minute; press Sync now to nudge)"
              else "Enter the Tiltify campaign URL in Settings"
              end]
    items << [event.enabled ? :ok : :no, "Event enabled",
              event.enabled ? "Chat entry, donation sync and draws are on" : "Enable it once the campaign is resolved"]
    fresh = event.last_complete_sync_at && event.last_complete_sync_at > 3.minutes.ago
    sync_state = fresh ? :ok : (event.enabled ? :wait : :no)
    items << [sync_state, "Donation sync running",
              event.last_complete_sync_at ? "Last complete sync #{time_ago_in_words(event.last_complete_sync_at)} ago" : "No complete sync yet"]
    items << [giveaways.any? ? :ok : :no, "At least one prize attached",
              giveaways.any? ? giveaways.map { |g| "!#{g.command_name}" }.join(", ") : "Add a prize on the Prizes tab"]
    items
  end

  def readiness_mark(state)
    { ok: ["ok", "✔"], no: ["no", "✖"], wait: ["wait", "…"] }.fetch(state)
  end
end
