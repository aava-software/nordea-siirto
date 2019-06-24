# Nordea::Siirto - implements Nordea Siirto protocol

Nordea::Siirto implements payment requests to specific Finnish banks, as specified in
[Siirto Specification](https://www.nordea.fi/yritysasiakkaat/palvelumme/tilit-maksut/siirto-yritysasiakkaille.html#tab=Palvelukuvaukset).

Gem currently implements
1. POST /auth         (Nordea::Siirto::AccessToken)
2. GET  /lookup/uuid  (Nordea::Siirto::Lookup)
3. POST /payment/pay  (Nordea::Siirto::Pay)

Client should call `Nordea::Siirto.pay` directly. Gem fetches and stores new access token, if previous one has expired.
Also Gem fetches new `lookupId` for each payment request automatically.

## Initialization
```ruby
  # Required parameters
  opts = {
    server: :test, # or :prod
    username: '<username>',
    api_token: '<api-token>'
  }

  Nordea::Siirto.setup(opts)
```

Initialization can be done only once.

### Optional initialization parameters

`Nordea::Siirto.setup` accepts the following optional parameters in the 'opts' hash.

* `:logger` - Custom logger, which implements `:info` method with String-parameter. Defaults to `Rails::Logger`.
* `:tag`    - Logging tag. Defaults to `"Nordea::Siirto"`.
* `:redis`  - Redis instance, or other storage, which has redis-like implementation for methods `:set, :expire, :get`. Defaults to `REDIS`.
* `:protocol` - Transfer protocol. Defaults to Nordea::Siirto::Protocols::NetHTTP (Ruby standard net/http implementation). Custom protocol can be supplied, as long as it implements `send_request` method, which takes in Nordea::Siirto::Request and returns Nordea::Siirto::Response. See current protocol implementations (lib/nordea/siirto/protocols/) for reference.

## Nordea::Siirto.pay

```ruby
  payload = {
    amount: 500, # cents, equal to 5,00€
    currency: 'EUR',
    bene_last_name: 'FamilyName',
    bene_first_names: ['FirstName', 'SecondName'], # must be an array
    bene_account_number: 'FI38 1572 3500 0456 61' # the only value test server will accept
  }
  Nordea::Siirto.pay(payload) # => Nordea::Siirto::Response object
```

Client must check code, message and body from the Response object.

Other allowed parameters are documented in Siirto documentation.
Parameters must be given in snake_case format. For instance parameter `beneficiaryMinimumAge` becomes `:beneficiary_minimun_age`.

## Run tests
```
  % bundle install
  % rspec test/lib/nordea/siirto
```

NOTE: With Aava specific system ruby, first select another ruby with `rvm use <ruby version`, then `bundle install`, and then make sure to have the selected ruby version's path in the load path.

## Contributions are welcome!

Contributions are welcome especially for implementing more requests, and improving test coverage.

