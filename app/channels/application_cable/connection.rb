module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless self.current_user
    end

    private

    def find_verified_user
      # Depending on how you authenticate your user, adjust the following line
      verified_user = env['warden'].user || reject_unauthorized_connection
      if verified_user
        verified_user
      else
        reject_unauthorized_connection
      end
    end

  end
end
