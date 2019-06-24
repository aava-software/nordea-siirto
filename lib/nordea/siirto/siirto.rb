module Nordea
  # This module is intended as the sole public API of this gem.
  #
  # AccessToken and Lookup requests are needed for actual processing
  # requests, such as Pay, to work. Client should not need to call them
  # directly, and therefore they are not directly callable from this module.
  #
  # A method handle for each request meant to be called directly by client,
  # should be included in this API.
  module Siirto
    # Nordea endpoints
    ENDPOINT = {
      prod: 'https://merchant.mobilewalletservices.nordea.com',
      test: 'https://merchant.trescomas.express'
    }.freeze

    # Only Nordea and OP supported at the moment
    ALLOWED_BIC = %w[NDEAFIHH OKOYFIHH].freeze

    # Singleton features implemented as such
    class << self
      # Mandatory params: Client must provide these at setup
      attr_reader :server, :username, :api_token

      # Optional params: Client may provide these at setup
      attr_reader :logger, :tag, :redis, :protocol

      # Make sure initialization is thread safe
      MUTEX = Mutex.new

      # Client must initialize Nordea::Siirto module before calling other
      # methods.
      #
      # @params opts [Hash] See README for details
      # @raise [Nordea::Siirto::InitializationError]
      # @return [Boolean]
      # rubocop:disable MethodLength
      def setup(opts)
        MUTEX.synchronize do
          allow_initialize?(opts)

          # Initialize
          opts.each do |key, val|
            attr = "@#{key}".to_sym
            instance_variable_set(attr, val)
          end

          # Client can inject logger of choice
          @logger ||= Rails.logger

          # Client can inject logging tag
          @tag ||= 'Nordea::Siirto --'

          # Client can inject REDIS instance of choice, or adapter.
          @redis ||= REDIS

          # Client can inject another Protocol
          @protocol ||= Protocols::NetHttp

          # Initialization complete
          log('Initialized!')
          true
        end
      end
      # rubocop:enable MethodLength

      # Checks if gem is already initialized with required parameters.
      # @return [Boolean]
      def initialized?
        server.present? && username.present? && api_token.present?
      end

      # 8.2. Send a payment using IBAN account number
      # POST /payment/pay
      #
      # @param payload [Hash] See README
      # @raise [Nordea::Siirto::Pay::InvalidIBAN]
      # @raise [Nordea::Siirto::Pay::InvalidPayload]
      # @return [Nordea::Siirto::Response]
      def pay(payload)
        Pay.pay(payload)
      end

      # Convenience method for requests
      # @return [String]
      def endpoint
        ENDPOINT[server]
      end

      # Convenience method for requests
      # @param msg [String]
      def log(msg)
        logger.info("#{tag} #{msg}")
      end

      private

      # Error messages
      ERROR = {
        already_initialized: 'Nordea::Siirto is already initialized.',
        missing_args: 'Invalid or missing arguments. Client must provide
          parameter hash with the following keys: :server (either :prod or
          :test), :username, :api_token.',
        invalid_logger: 'Logger must respond to :info method.',
        invalid_protocol: 'Protocol must respond to :send_request method'
      }.freeze

      # Checks that module has not been previously initialized, and
      # that arguments are more or less acceptable.
      # @raise [Nordea::Siirto::InitializationError]
      # rubocop:disable AbcSize,CyclomaticComplexity,GuardClause
      def allow_initialize?(opts)
        raise InitializationError, ERROR[:already_initialized] if initialized?
        raise InitializationError, ERROR[:missing_args] if missing_args?(opts)
        if opts[:logger] && !opts[:logger].respond_to?(:info)
          raise InitializationError, ERROR[:invalid_logger]
        end
        if opts[:protocol] && !opts[:protocol].respond_to?(:send_request)
          raise InitializationError, ERROR[:invalid_protocol]
        end
      end
      # rubocop:enable AbcSize,CyclomaticComplexity,GuardClause

      # Checks that required parameters are present.
      # @return [Boolean]
      def missing_args?(opts)
        !(opts[:server] && opts[:username] && opts[:api_token] &&
          ENDPOINT.keys.include?(opts[:server].to_sym))
      end
    end
  end
end
