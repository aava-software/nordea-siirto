# Nordea::Siirto

Client for Nordea Bank's [Siirto API](https://www.nordea.fi/yritysasiakkaat/palvelumme/tilit-maksut/siirto-yritysasiakkaille.html#tab=Palvelukuvaukset), which enables payments to specific Finnish banks.

Gem currently implements the following requests:

Module | Description | Method | Endpoint
---|---|---|---
Nordea::Siirto::AccessToken | Fetches access token from remote and stores it, if previous one has expired. | POST | /auth
Nordea::Siirto::Lookup | Fetches new LookupId for each payment request, when `Nordea::Siirto.pay` is called | GET  | /lookup/uuid
Nordea::Siirto::Pay | Sends Iban payment. Client should call `Nordea::Siirto.pay` directly | POST | /payment/pay

`Nordea::Siirto` defines the gem's intended public interface. 
Client should call `Nordea::Siirto.setup` and `Nordea::Siirto.pay` as described below. 

## Initialization

```ruby
  opts = {
    server: :test, # or :prod
    username: '<username>',
    api_token: '<api-token>'
  }

  Nordea::Siirto.setup(opts)
```

Initialization can be done only once.

### Required initialization parameters

Params | Description | Value
---|---|---
:server | Select either test or production server | `:test` OR `:prod`
:username | Siirto customer's username | String
:api_token | Siirto customer's api token | String

### Optional initialization parameters

Param | Description | Default value
---|---|---
:logger | Logger, must implement `:info` method that takes in String-parameter. | Rails::Logger
:tag | Logging tag. | "Nordea::Siirto"
:redis | Redis instance, or other storage, which has redis-like implementation for methods `:set, :expire, :get`. | REDIS
:protocol | HTTP protocol. See current protocol implementations for reference. | Nordea::Siirto::Protocols::NetHttp.new

## Requests

### Nordea::Siirto.pay

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

Client should check `code` (http status), `message` and `body` values from the `Response` object.

Other allowed parameters are documented in Siirto documentation.
Parameters must be given in snake_case format. For instance parameter `beneficiaryMinimumAge` becomes `:beneficiary_minimun_age`.

## Run tests
```
  % bundle install
  % rspec test/lib/nordea/siirto
```
