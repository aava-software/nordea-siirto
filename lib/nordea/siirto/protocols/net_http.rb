module Nordea
  module Siirto
    # NOTE: NOT COVERED BY TEST SET
    module Protocols
      # Implements communication with Nordea server using Ruby's standard
      # net/http library
      module NetHttp
        module_function

        # Public interface of the protocol implementation
        # @param [Nordea::Siirto::Request]
        # @return [Nordea::Siirto::Response]
        # rubocop:disable MethodLength,AbcSize,LineLength
        def send_request(siirto_request)
          uri = siirto_request.uri
          Nordea::Siirto.log("Sending request to: #{uri}")

          # Get response
          request = create_request(siirto_request)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.port == 443
          http_response = http.request(request)

          # Pack response
          response = Nordea::Siirto::Response.new
          response.code = http_response.code
          response.body = JSON.parse(http_response.body)
          response.message = http_response.message

          # Log response
          if response.body['access_token'] # do not log token
            Nordea::Siirto.log("Server responds: #{response.message} #{response.code}")
          else
            Nordea::Siirto.log("Server responds: #{response.message} #{response.code} #{response.body}")
          end

          response
        rescue StandardError => e
          Nordea::Siirto.log("Fails: #{e.message}")
          raise
        end
        # rubocop:enable MethodLength,AbcSize,LineLength

        # Private convenience method
        # Transforms generic siirto request into a protocol-specific request.
        # @param [Nordea::Siirto::Request]
        # @return [Net::HTTPRequest]
        def format_request(siirto_request)
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
      end
    end
  end
end
