module Nordea
  module Siirto
    # Fetches unique LookupId from Nordea server.
    # LookupId is required to make a payment request.
    module Lookup
      module_function

      # @return [Hash]
      def lookup
        response = Nordea::Siirto.protocol.send_request(request)
        response.body
      end

      # @return [URI::HTTPS]
      def uri
        @uri ||= URI.parse("#{Nordea::Siirto.endpoint}/lookup/uuid")
      end

      # @return [Nordea::Siirto::Request]
      def request
        request = Nordea::Siirto::Request.new
        request.uri = uri
        request.method = 'GET'
        request.headers = {
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{AccessToken.access_token}"
        }
        request
      end

      # @return [Nordea::Siirto::Response]
      def response
        Nordea::Siirto.protocol.send_request(request)
      end
    end
  end
end
