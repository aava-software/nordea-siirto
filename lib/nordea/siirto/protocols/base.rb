module Nordea
  module Siirto
    # NOTE: NOT COVERED BY TEST SET
    module Protocols
      # This class may be used as a base class for protocol implementations.
      # Sub-classes should implement :send_request and :parse_response methods
      # correctly.
      #
      # Gem expects protocol implementation to respond to :send! method, which
      # takes in a generic Siirto request object, and returns a generic Siirto
      # response object.
      class Base
        # Public interface of protocol implementations
        # @param [Nordea::Siirto::Request]
        # @return [Nordea::Siirto::Response]
        # rubocop:disable MethodLength,AbcSize,LineLength
        def send!(request)
          uri = request.uri
          Nordea::Siirto.log("Sending request to: #{uri}")

          # Send request
          begin
            protocol_response = send_request(request)
          rescue StandardError => e
            Nordea::Siirto.log("Failed to send request: #{request.inspect} #{e.message}")
            raise
          end

          # Parse response
          begin
            response = parse_response(protocol_response)
          rescue StandardError => e
            Nordea::Siirto.log("Failed to parse response: #{protocol_response.inspect} #{e.message}")
            raise
          end

          # Log response
          message = "Server responds: #{response.message}"
          message << " #{response.code}"
          unless response.body['access_token'] # do not log token
            message << " #{response.body}"
          end
          Nordea::Siirto.log(message)

          response
        end
        # rubocop:enable MethodLength,AbcSize,LineLength

        private

        # Sub-class must implement
        # @param [Nordea::Siirto::Request]
        # @return [Object] Protocol-specific response object
        def send_request(request)
          raise NotImplementedError, 'Sub-class must implement'
        end

        # Sub-class must implement
        # @params [Object] Protocol-specific response object
        # @return [Nordea::Siirto::Response]
        def parse_response(protocol_response)
          raise NotImplementedError, 'Sub-class must implement'
        end
      end
    end
  end
end

