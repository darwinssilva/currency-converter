require 'rails_helper'

RSpec.describe "Conversions", type: :request do
  let(:user) { create(:user) }

  before do
    stub_request(:get, /currencyapi.com/).to_return(
      status: 200,
      body: {
        data: {
          'BRL' => { 'value' => 5.25 }
        }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  describe 'POST /convert' do
    context 'with valid parameters' do
      it 'returns the converted value and saves transaction' do
        expect do
          post '/convert', params: {
            user_id: user.id,
            from_currency: 'USD',
            to_currency: 'BRL',
            amount: 100
          }
        end.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['from_currency']).to eq('USD')
        expect(json['to_currency']).to eq('BRL')
        expect(json['from_value']).to eq(100.0)
        expect(json['to_value']).to eq(525.0)
        expect(json['rate']).to eq(5.25)
      end
    end

    context 'with invalid user' do
      it 'returns not found' do
        post '/convert', params: {
          user_id: 0,
          from_currency: 'USD',
          to_currency: 'BRL',
          amount: 100
        }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('User not found')
      end
    end

    context 'with invalid currency' do
      it 'returns unprocessable entity' do
        post '/convert', params: {
          user_id: user.id,
          from_currency: 'XXX',
          to_currency: 'BRL',
          amount: 100
        }

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['error']).to eq('Invalid currency code')
      end
    end

    context 'when API fails' do
      before do
        stub_request(:get, /currencyapi.com/).to_return(status: 500)
      end

      it 'returns bad gateway' do
        post '/convert', params: {
          user_id: user.id,
          from_currency: 'USD',
          to_currency: 'BRL',
          amount: 100
        }

        expect(response).to have_http_status(:bad_gateway)
        expect(JSON.parse(response.body)['error']).to eq('Could not fetch exchange rate')
      end
    end
  end
end
