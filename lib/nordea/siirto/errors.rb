module Nordea
  # Gem specific errors
  module Siirto
    class InitializationError < StandardError; end

    # Errors used by Pay module
    module Pay
      class InvalidIBAN < ArgumentError; end
      class InvalidPayload < ArgumentError; end
    end
  end
end
