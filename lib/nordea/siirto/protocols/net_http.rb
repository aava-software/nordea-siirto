module Nordea
  module Siirto
    # NOTE: NOT COVERED BY TEST SET
    module Protocols
      # Implements communication with Nordea server using Ruby's standard
      # net/http library
      class NetHttp < Base
        private

        # Creates protocol-specific request from generic Siirto request
        # @param [Nordea::Siirto::Request]
        # @return [Net::HTTPRequest]
        def create_request(siirto_request)
          # Extract data
          klass = "Net::HTTP::#{siirto_request.method.capitalize}".constantize
          uri = siirto_request.uri.request_uri
          body = siirto_request.body
          headers = siirto_request.headers

          # Create new Request object
          request = klass.new(uri)
          headers.each do |header, value|
            request[header] = value
          end
          request.body = body if body.present?
          request
        end

        # Makes the actual request
        # @param [Nordea::Siirto::Request]
        # @return [Net::HTTPRequest]
        def send_request(siirto_request)
          request = create_request(siirto_request)
          uri = siirto_request.uri
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.port == 443
          http.request(request)
        end

        # Parses NET::HTTPResponse into a generic Siirto response
        # @param [Net::HTTPResponse]
        # @return [Nordea::Siirto::Response]
        def parse_response(http_response)
          response = Nordea::Siirto::Response.new
          response.code = http_response.code
          response.body = JSON.parse(http_response.body)
          response.message = http_response.message
        end
      end
    end
  end
end
