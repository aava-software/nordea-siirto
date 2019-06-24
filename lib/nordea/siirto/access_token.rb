module Nordea
  module Siirto
    # Responsible for fetching access token from the server,
    # and memoizing it.
    module AccessToken
      # Store current access token into REDIS
      KEY = 'Nordea::Siirto::AccessToken'.freeze
      EXPIRATION_BUFFER = 20 # seconds, arbitrary
      MUTEX = Mutex.new

      module_function

      # Fetches access token from server if previous token has expired
      # Memoizes token, and sets expiration time, with some buffer.
      # @return [String]
      # rubocop:disable MethodLength
      def access_token
        # Synchronization is needed, otherwise race condition may ensue:
        # Let's assume token has expired, and two threads ask for a new token.
        # Both proceed to fetch the token from remote server, both return,
        # but the first token is no longer valid.
        MUTEX.synchronize do
          token = Nordea::Siirto.redis.get(KEY)
          return token if token

          Nordea::Siirto.log('Requesting new access token...')
          payload = response.body

          token = payload['access_token']
          expires_in = payload['expires_in'] - EXPIRATION_BUFFER
          Nordea::Siirto.redis.set(KEY, token)
          Nordea::Siirto.redis.expire(KEY, expires_in)

          token
        end
      end
      # rubocop:enable MethodLength

      # @return [URI::HTTPS]
      def uri
        @uri ||= URI.parse("#{Nordea::Siirto.endpoint}/auth")
      end

      # @return Nordea::Siirto::Request
      # rubocop:disable MethodLength
      def request
        request = Nordea::Siirto::Request.new
        request.uri = uri
        request.method = 'POST'
        request.headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
        request.body = {
          grant_type: 'password',
          username:   Nordea::Siirto.username,
          password:   Nordea::Siirto.api_token,
          client_id:  Nordea::Siirto.username
        }.to_query
        request
      end
      # rubocop:enable MethodLength

      # @return [Nordea::Siirto::Response]
      def response
        Nordea::Siirto.protocol.send_request(request)
      end
    end
  end
end
