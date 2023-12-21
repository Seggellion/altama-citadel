module JsonRequestParser
    extend ActiveSupport::Concern
  
    def parse_json_request
      @json_request ||= JSON.parse(request.body.read)
    end
  end
  