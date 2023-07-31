class StarBitizenChannel < ApplicationCable::Channel
    def subscribed
      
        stream_from "star_bitizen_channel"
        Rails.logger.info "Successfully subscribed to StarBitizenChannel"
    end
    def unsubscribed
      stop_all_streams
    end
  end
  