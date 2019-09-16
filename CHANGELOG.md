# CHANGELOG

## 1.0.0 (24-Jun-2019)

First version of the gem.

## 2.0.0 (4-Sep-2019)

Refactor protocols: Breaking change to initializing gem,
see README for details.

Raise MissingLookuIp in case lookup_id cannot be retrieved.

Improved documentation.

## 2.0.1 (16-Sep-2019)

Add warnings to Nordea::Siirto::Protocols::Curl.
We should ideally wrap a Java HTTP library, for JRuby legacy versions, in case
Ruby net/http cannot be used.

Update tests.
