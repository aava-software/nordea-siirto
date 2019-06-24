module Nordea
  module Siirto
    # Generic data class which Protocol implementations can use
    class Request
      attr_accessor :uri, :body, :headers, :method
    end
  end
end
