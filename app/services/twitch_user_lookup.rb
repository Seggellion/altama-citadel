require "net/http"

# Resolves Twitch accounts through Helix Get Users with an app access token (client credentials).
# Errors raise TwitchUserLookup::Error; "not found" returns nil. Never logs tokens or response bodies.
class TwitchUserLookup
  Error = Class.new(StandardError)
  User = Struct.new(:id, :login, :display_name, keyword_init: true)

  class << self
    attr_writer :backend

    def backend
      @backend ||= new
    end

    def by_login(login)
      backend.by_login(login)
    end

    def by_id(id)
      backend.by_id(id)
    end
  end

  LOGIN_SYNTAX = /\A[a-z0-9_]{1,25}\z/

  def by_login(login)
    login = login.to_s.strip.downcase
    return nil unless LOGIN_SYNTAX.match?(login)

    get_users(login: login).first
  end

  def by_id(id)
    return nil unless id.to_s.match?(/\A\d+\z/)

    get_users(id: id.to_s).first
  end

  private

  def get_users(params)
    attempts = 0
    begin
      attempts += 1
      uri = URI("https://api.twitch.tv/helix/users")
      uri.query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new(uri)
      req["Client-Id"] = client_id
      req["Authorization"] = "Bearer #{token}"
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) { |h| h.request(req) }
      if res.code == "401" && attempts == 1
        @token = nil
        raise Error, "retry"
      end
      raise Error, "twitch_http_#{res.code}" unless res.code == "200"

      JSON.parse(res.body).fetch("data").map { |u| User.new(id: u["id"].to_s, login: u["login"].downcase, display_name: u["display_name"]) }
    rescue Error => e
      retry if e.message == "retry"
      raise
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED, JSON::ParserError, KeyError => e
      raise Error, "twitch_unavailable (#{e.class.name})"
    end
  end

  def client_id
    ENV.fetch("TWITCH_CLIENT_ID") { raise Error, "twitch_credentials_missing" }
  end

  def token
    @token ||= begin
      res = Net::HTTP.post_form(URI("https://id.twitch.tv/oauth2/token"),
                                client_id: client_id, client_secret: ENV.fetch("TWITCH_CLIENT_SECRET") { raise Error, "twitch_credentials_missing" },
                                grant_type: "client_credentials")
      raise Error, "twitch_token_http_#{res.code}" unless res.code == "200"

      JSON.parse(res.body).fetch("access_token")
    end
  end
end
