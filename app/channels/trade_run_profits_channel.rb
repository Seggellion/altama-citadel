class TradeRunProfitsChannel < ApplicationCable::Channel
  def subscribed
    if params[:trade_session_id].present?
      stream_from "trade_run_profits_channel_#{params[:trade_session_id]}"
      Rails.logger.info "Successfully subscribed to TradeRunProfitsChannel"
    else
      reject
    end
  end
  def unsubscribed
    stop_all_streams
  end
end
