# Canonical Twitch identity, keyed by Twitch's opaque, stable user id (stored as a string).
class TwitchAccount < ApplicationRecord
  belongs_to :user, optional: true
  validates :twitch_user_id, presence: true, uniqueness: true, format: { with: /\A\d+\z/ }
  validates :login, presence: true

  def label
    display_name.presence && display_name.casecmp?(login) ? "#{display_name} (#{twitch_user_id})" : "#{login} (#{twitch_user_id})"
  end
end
