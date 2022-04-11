
class DiscordUser < ApplicationRecord


def authenticate(hash, user, discord_name)
discord_auth(hash, user, discord_name)
end

end
