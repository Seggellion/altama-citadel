# app/channels/status_updates_channel.rb
class StatusUpdatesChannel < ApplicationCable::Channel
    def subscribed
      stream_from "status_updates"
      puts "Subscribed to StatusUpdatesChannel"
      Rails.logger.info "Client subscribed to StatusUpdatesChannel"

    end
  
    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end
  end
  