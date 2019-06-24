module Nordea
  module Siirto
    # Generic data class which Protocol implementations should return
    class Response
      attr_accessor :code, :message, :body
    end
  end
end
