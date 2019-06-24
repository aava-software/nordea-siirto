require_relative 'spec_helper'

# Test describes how to initialize Nordea::Siirto module
# Initialization can be done for instance in config/initializers
RSpec.describe 'Nordea::Siirto.setup' do
  before(:all) { reset_siirto }

  it 'initializes properly' do
    # Requires server, username, api_token as parameters.
    # Server value must be acceptable (:test, :prod)
    expect do
      Nordea::Siirto.setup(server: :blank, username: 'present', api_token: 'present')
    end.to raise_error(Nordea::Siirto::InitializationError)

    # Logger must respond to :info
    not_ok_params = siirto_params.merge(logger: Object.new)
    expect do
      Nordea::Siirto.setup(not_ok_params)
    end.to raise_error(Nordea::Siirto::InitializationError)

    # Initializes OK with proper params
    Nordea::Siirto.setup(siirto_params)
    expect(Nordea::Siirto.logger).to be_a(MyLogger)
    expect(Nordea::Siirto.username).to eql(siirto_params[:username])
    expect(Nordea::Siirto.api_token).to eql(siirto_params[:api_token])
    expect(Nordea::Siirto.server).to eql(:test)
    expect(Nordea::Siirto.redis).to be_a(Object)

    # Cannot be initialized twice
    expect do
      Nordea::Siirto.setup(siirto_params)
    end.to raise_error(Nordea::Siirto::InitializationError)
  end

  it 'delegates to Pay' do
    allow(Nordea::Siirto::Pay).to receive(:pay)

    Nordea::Siirto.pay('jee')
  end
end

