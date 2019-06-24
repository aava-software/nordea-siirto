require_relative 'lib/nordea/siirto/version'

Gem::Specification.new do |spec|
  spec.name = 'nordea-siirto'
  spec.version = Nordea::Siirto::VERSION
  spec.summary = 'Nordea Siirto requests'
  spec.description = <<-DESCRIPTION
    Nordea::Siirto implements requests according to Nordea Siirto protocol,
    which enables real time payments for select Finnish bank accounts
  DESCRIPTION
  spec.authors = ['Matilda Smeds']
  spec.email = 'foss@aavasoftware.com'
  spec.files = ['lib/nordea/siirto.rb'] + Dir['lib/nordea/siirto/*.rb']
  spec.license = 'MIT'
end
