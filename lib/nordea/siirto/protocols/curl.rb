module Nordea
  module Siirto
    # NOTE: NOT COVERED BY TEST SET
    module Protocols
      # Implements communication with Nordea server using command line cURL.
      # Provided as an alternative protocol for net/http, as some ruby
      # implementations fail to complete SSL Handshake with Nordea servers.
      # At least JRuby 1.9.17 falls in this category.
      module Curl
        module_function

        # Public interface of the protocol implementation
        # @param [Nordea::Siirto::Request]
        # @return [Nordea::Siirto::Response]
        # rubocop:disable MethodLength,AbcSize,LineLength
        def send_request(siirto_request)
          Nordea::Siirto.log("Sending request to: #{siirto_request.uri}")

          request = format_request(siirto_request)
          curl_response = IO.popen(request)
          response = pack_response(curl_response)

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
        # Parses curl response string and returns a generic siirto response
        # @params [String]
        # @return [Nordea::Siirto::Response]
        def pack_response(curl_response)
          lines = curl_response.readlines
          code = lines.first.split(' ').last
          body = JSON.parse(lines.last)

          response = Nordea::Siirto::Response.new
          response.code = code
          # Nordea server responds to curl in HTTP/2, and apparently in HTTP/2
          # there is no standard way to return HTTP status message (e.g. OK, Not
          # Found), unlike in HTTP/1.1. We would need to either force HTTP/1.1
          # or map status codes to messages here.
          response.message = ''
          response.body = body
          response
        end

        # Private convenience method
        # Parses generic siirto request and returns curl command string
        # @param [Nordea::Siirto::Request]
        # @return [String]
        def format_request(siirto_request)
          # i - show information, not just response body
          # s - hide statusbar, error information
          request = "curl -X #{siirto_request.method} -is"
          siirto_request.headers.each do |header, value|
            request << " --header '#{header}: #{value}'"
          end
          if (body = siirto_request.body).present?
            request << " --data '#{body}'"
          end
          request << " #{siirto_request.uri}"
          request
        end
      end
    end
  end
end
