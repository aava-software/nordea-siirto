module Nordea
  module Siirto
    # Implements Nordea Siirto IBAN payments.
    module Pay
      # Accepted parameters
      PARAMS = {
        required: %i[amount currency bene_account_number],
        person: %i[bene_first_names bene_last_name],
        company: %i[bene_company_name],
        optional: %i[fallback_payment reference_number payment_message
                     ultimate_bene_ref_name beneficiary_minimum_age
                     beneficiary_identifier]
      }.freeze

      module_function

      # @param [Hash] See README
      # @return [Nordea::Siirto::Response]
      def pay(params) # :nodoc:
        raise InvalidPayload unless valid_payload?(params)
        raise InvalidIBAN unless valid_iban?(params)

        response(params)
      end

      # @return [URI::HTTPS]
      def uri # :nodoc:
        @uri ||= URI.parse("#{Nordea::Siirto.endpoint}/payment/pay")
      end

      # @param [Hash]
      # @return [Nordea::Siirto::Response]
      def response(params)
        Nordea::Siirto.protocol.send_request(request(params))
      end

      # @param [Hash]
      # @return [Hash]
      def format_params(params) # :nodoc:
        hash = params.map do |key, val|
          # dromedar case required
          str = key.to_s.camelize
          str[0] = str[0].downcase
          { str => val }
        end.reduce(&:merge)
        # unique lookupId is needed for each payment request
        # we add it to params here
        #
        # TODO LOOKUP REQUEST MAY FAIL
        hash.merge(Lookup.lookup.slice('lookupId'))
      end

      # @param [Hash]
      # @return [Nordea::Siirto::Request]
      # rubocop:disable MethodLength
      def request(params)
        request = Nordea::Siirto::Request.new
        request.uri = uri
        request.method = 'POST'
        request.headers = {
          'Accept' => 'application/json',
          'Content-type' => 'application/json',
          'Authorization' => "Bearer #{AccessToken.access_token}"
        }
        request.body = format_params(params).to_json
        Nordea::Siirto.log("Body: #{request.body}")
        request
      end
      # rubocop:enable MethodLength

      # @param [Hash]
      # @return [Boolean]
      def valid_iban?(params)
        # It makes sense to check IBAN validity and bank compatibility before
        # sending request
        iban = Iban.new(params[:bene_account_number])
        return false unless iban.validate

        ALLOWED_BIC.include?(iban.bic)
      end

      # @param [Hash]
      # @return [Boolean]
      # rubocop:disable AbcSize,LineLength
      def valid_payload?(params)
        params_present = lambda do |key|
          (params.keys & PARAMS[key]).size == PARAMS[key].size
        end

        # required params present
        return false unless params_present.call(:required)

        # either person or company params present
        return false if params_present.call(:person) && params_present.call(:company)
        return false unless params_present.call(:person) || params_present.call(:company)

        # must not contain other params than those listed above
        (params.keys - PARAMS.values.flatten).size.zero?
      end
      # rubocop:enable AbcSize,LineLength
    end
  end
end
