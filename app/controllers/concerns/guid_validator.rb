module GuidValidator
    extend ActiveSupport::Concern
  
    def validate_secret_guid
      @secretguid = ENV['STARBITIZEN_EXCHANGE']
      received_guid = @json_request["secretguid"]
  
      unless @secretguid == received_guid
        render json: { error: 'Invalid secret guid' }, status: :unauthorized
        return
      end
    end
    
  end
  