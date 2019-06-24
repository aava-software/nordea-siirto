require_relative 'spec_helper.rb'

RSpec.describe 'Nordea::Siirto::Lookup' do
  before(:all) { initialize_siirto_unless_initialized }

  it 'creates request correctly' do
    allow(Nordea::Siirto::AccessToken).to receive(:access_token).and_return('Tao tao')
    request = Nordea::Siirto::Lookup.request

    expect(request).to be_a(Nordea::Siirto::Request)
    expect(request.method).to eql('GET')
    expect(request.uri.path).to eql('/lookup/uuid')

    headers = request.headers
    expect(headers['Accept']).to eql('application/json')
    expect(headers['Authorization']).to eql('Bearer Tao tao')
  end
end
