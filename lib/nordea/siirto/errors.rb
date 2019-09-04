module Nordea
  # Gem specific errors
  module Siirto
    class InitializationError < StandardError; end

    # Errors used by Pay module
    module Pay
      class InvalidIBAN < ArgumentError; end
      class InvalidPayload < ArgumentError; end
      class MissingLookupId < StandardError; end
    end
  end
end
