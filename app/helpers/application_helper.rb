module ApplicationHelper
    
    def comment
    end

    def bbs_link_for(user)
        "https://bbs.altama.energy?token=#{generate_jwt(user)}"
    end

    def generate_jwt(user)
        expiration = 24.hours.from_now.to_i
        payload = { user_id: user.id, exp: expiration }
      
        # Manually invoke Warden JWT Auth's token encoder
        encoder = Warden::JWTAuth::TokenEncoder.new
        token, _payload = encoder.call(payload)
      
        token
      end

end
