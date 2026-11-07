module StreamOverlayHelper
  STREAM_TIME_ZONE = "America/Vancouver".freeze

  def stream_auec(n) = "#{number_with_delimiter(n)} aUEC"

  # +175,000 aUEC / −55,000 aUEC (true minus sign) / 0 aUEC
  def stream_signed_auec(n)
    return stream_auec(0) if n.zero?

    "#{n.positive? ? '+' : '−'}#{stream_auec(n.abs)}"
  end

  def stream_net_class(n) = n.positive? ? "gain" : (n.negative? ? "loss" : "even")

  def stream_days_text(d) = "#{d} day#{'s' unless d == 1}"

  def stream_time(t) = t&.in_time_zone(STREAM_TIME_ZONE)&.strftime("%b %-d, %-I:%M %p %Z")
end
