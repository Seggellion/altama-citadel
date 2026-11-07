# Public, read-only OBS Browser Source: GET /overlay/:token (page) and /overlay/:token.json (polled every 3 s).
#
# Deliberately not an ApplicationController: no login, no session cookie, no layout (so no analytics or memos),
# and its own error handling, because ApplicationController swallows production errors into an empty response.
# Only StreamOverlay#payload leaves this controller: the net aUEC and the accident day count, never balances.
class StreamOverlaysController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :skip_session
  before_action :no_store
  before_action :set_overlay

  rescue_from StandardError do |e|
    Rails.logger.error("[overlay] #{e.class}: #{e.message}")
    respond_to do |format|
      format.json { render json: { v: 1, error: "unavailable" }, status: :service_unavailable }
      format.any { head :service_unavailable }
    end
  end

  def show
    @payload = @overlay.payload
    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @payload }
    end
  end

  private

  def skip_session
    request.session_options[:skip] = true
  end

  def no_store
    response.headers["Cache-Control"] = "no-store"
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
    response.headers["Referrer-Policy"] = "no-referrer"
  end

  def set_overlay
    @overlay = StreamOverlay.find_by_token(params[:token])
    head :not_found unless @overlay
  end
end
