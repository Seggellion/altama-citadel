# The public OBS Browser Source for one bot. The URL carries a random token; only its SHA-256 digest is stored, so
# the URL can't be recovered from the database and rotating the token revokes the old URL immediately.
class StreamOverlay < ApplicationRecord
  DEFAULT_CAPTION = "Days since last fuelling accident".freeze
  TOKEN_FORMAT = /\A[A-Za-z0-9_-]{43}\z/

  belongs_to :bot

  validates :accident_caption, presence: true, length: { maximum: 60 }

  def self.digest(token) = Digest::SHA256.hexdigest(token.to_s)

  def self.find_by_token(token)
    return nil unless token.to_s.match?(TOKEN_FORMAT)

    find_by(token_digest: digest(token), enabled: true)
  end

  def self.for_bot(bot) = find_or_create_by!(bot: bot)

  # Returns the new plaintext token. Show it to the admin once; it is not stored.
  def rotate_token!
    token = SecureRandom.urlsafe_base64(32)
    update!(token_digest: self.class.digest(token), token_rotated_at: Time.current)
    token
  end

  def token? = token_digest.present?

  # Everything the public overlay may show. No balances, ids, names or timestamps of the accident.
  def payload(as_of: nil)
    session = bot.stream_wallet_sessions.order(started_at: :desc, id: :desc).first
    # An ended session no longer drives the overlay: only a running session's net is public.
    wallet = if session.nil? then { state: "not_started" }
             elsif session.active? then { state: "active", net_auec: session.net_auec }
             else { state: "ended" }
             end
    current = FuellingAccident.current_for(bot.channel, as_of: as_of)
    accident = current ? { state: "recorded", days: current.days } : { state: "none" }
    { v: 1, wallet: wallet, accident: accident.merge(caption: accident_caption), generated_at: Time.current.utc.iso8601 }
  end
end
