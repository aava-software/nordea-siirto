require_relative 'spec_helper'

# Test describes Nordea::Siirto.pay method and expected payload
RSpec.describe 'Nordea::Siirto::Pay' do
  before(:all) { initialize_siirto_unless_initialized }
  let(:params) do
    {
      amount: 400, # 4,00
      currency: 'EUR',
      bene_last_name: 'Ankka',
      bene_first_names: ['Iines'],
      bene_account_number: 'FI38 1572 3500 0456 61',
      payment_message: 'Testi-tilitys'
    }
  end

  it 'creates request correctly' do
    allow(Nordea::Siirto::AccessToken).to receive(:access_token).and_return('Star Trek')
    allow(Nordea::Siirto::Lookup).to receive(:lookup).and_return({ 'lookupId' => 'Babylon 5' })
    allow(Nordea::Siirto::Pay).to receive(:response)

    request = Nordea::Siirto::Pay.request(params)

    expect(request).to be_a(Nordea::Siirto::Request)
    expect(request.method).to eql('POST')
    expect(request.uri.path).to eql('/payment/pay')

    headers = request.headers
    expect(headers['Accept']).to eql('application/json')
    expect(headers['Authorization']).to eql('Bearer Star Trek')

    body = JSON.parse(request.body)
    expect(body['beneAccountNumber']).to eql(params[:bene_account_number])
    expect(body['lookupId']).to eql('Babylon 5')
  end

  it 'checks if bank is supported' do
    # With invalid iban
    invalid_params = params.merge(bene_account_number: 'FI13131313131313')
    expect { Nordea::Siirto::Pay.pay(invalid_params) }.to raise_error Nordea::Siirto::Pay::InvalidIBAN

    # With valid iban
    allow(Nordea::Siirto::Pay).to receive(:response)
    expect { Nordea::Siirto::Pay.pay(params) }.not_to raise_error
  end

  it 'checks for mandatory params' do
    expect do
      Nordea::Siirto::Pay.pay(greeting: 'Guten Morgen!')
    end.to raise_error Nordea::Siirto::Pay::InvalidPayload
  end
end
