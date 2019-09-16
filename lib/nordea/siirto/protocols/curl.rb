module Nordea
  module Siirto
    # NOTE: NOT COVERED BY TEST SET
    module Protocols
      # Implements communication with Nordea server using command line cURL.
      # Provided as an alternative protocol for net/http, as some Ruby
      # implementations fail to complete SSL Handshake with Nordea servers.
      # At least JRuby 1.9.17 falls in this category.
      #
      # WARNING: We cannot guarantee what Nordea::Siirto::Response#code
      # will contain. With legacy JRuby, a better way (next to upgrading)
      # would be to wrap sufficiently modern and robust Java HTTP library.
      # That way server responses would be more reliable.
      class Curl < Base
        private

        # Parses generic Siirto request and returns curl command string
        # @param [Nordea::Siirto::Request]
        # @return [String]
        def create_request(siirto_request)
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

       # Makes the actual request
       # @param [Nordea::Siirto::Request]
       # @return [Net::HTTPRequest]
       def send_request(siirto_request)
          request = create_request(siirto_request)
          IO.popen(request)
        end

        # Parses curl response string and returns a generic Siirto response
        # @params [String]
        # @return [Nordea::Siirto::Response]
        def parse_response(curl_response)
          lines = curl_response.readlines
          # Absence of network connection
          raise IOError, 'Curl response empty' if lines.blank?

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
      end
    end
  end
end
