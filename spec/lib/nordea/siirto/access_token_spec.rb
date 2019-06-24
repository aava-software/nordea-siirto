require_relative 'spec_helper.rb'

RSpec.describe 'Nordea::Siirto::AccessToken' do
  before(:all) { initialize_siirto_unless_initialized }
  let(:redis) { Nordea::Siirto.redis }
  let(:redis_key) { Nordea::Siirto::AccessToken::KEY }

  it 'creates request correctly' do
    request = Nordea::Siirto::AccessToken.request

    expect(request).to be_a(Nordea::Siirto::Request)
    expect(request.method).to eql('POST')
    expect(request.uri.path).to eql('/auth')

    headers = request.headers
    expect(headers ['Accept']).to eql('application/json')
    expect(headers ['Content-Type']).to eql('application/x-www-form-urlencoded')

    expect(request.body).to include('username')
    expect(request.body).to include('password')
    expect(request.body).to include('grant_type=password')
  end

  it 'stores access token to Redis' do
    allow(redis).to receive(:get).with(redis_key)

    # We mock the response, instead of attempting request
    mock_response = Nordea::Siirto::Response.new
    mock_response.body = { 'access_token' => 'hello', 'expires_in' => 400 }
    allow(Nordea::Siirto::AccessToken).to(
      receive(:response).and_return(mock_response)
    )
    allow(redis).to receive(:set).with(redis_key, 'hello')
    allow(redis).to receive(:expire).with(redis_key, 380)

    expect(Nordea::Siirto::AccessToken.access_token).to eql('hello')
  end

  it 'retrieves existing access token from Redis' do
    allow(redis).to receive(:get).with(redis_key).and_return(1)

    expect(Nordea::Siirto::AccessToken.access_token).to eql(1)
  end
end
