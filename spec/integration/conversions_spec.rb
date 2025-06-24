# spec/integration/conversions_spec.rb
require 'swagger_helper'

RSpec.describe 'Conversions API', type: :request do
  path '/convert' do
    post 'Convert currency' do
      tags 'Conversions'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :conversion, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer, example: 1 },
          from_currency: { type: :string, example: 'USD' },
          to_currency: { type: :string, example: 'BRL' },
          amount: { type: :number, example: 100.0 }
        },
        required: %w[user_id from_currency to_currency amount]
      }

      response '201', 'Conversion successful' do
        let(:user) { User.create!(name: 'John Doe', email: 'john@example.com') }

        let(:conversion) do
          {
            user_id: user.id,
            from_currency: 'USD',
            to_currency: 'BRL',
            amount: 100.0
          }
        end

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

        schema type: :object,
               properties: {
                 transaction_id: { type: :integer, example: 123 },
                 user_id: { type: :integer, example: 1 },
                 from_currency: { type: :string, example: 'USD' },
                 to_currency: { type: :string, example: 'BRL' },
                 from_value: { type: :number, example: 100.0 },
                 to_value: { type: :number, example: 525.0 },
                 rate: { type: :number, example: 5.25 }
               }

        run_test!
      end

      response '404', 'User not found' do
        let(:conversion) do
          {
            user_id: 9999,
            from_currency: 'USD',
            to_currency: 'BRL',
            amount: 100.0
          }
        end

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

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'User not found' }
               }

        run_test!
      end

      response '422', 'Invalid currency code' do
        let(:user) { User.create!(name: 'John Doe', email: 'john@example.com') }

        let(:conversion) do
          {
            user_id: user.id,
            from_currency: 'INVALID',
            to_currency: 'BRL',
            amount: 100.0
          }
        end

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Invalid currency code' }
               }

        run_test!
      end

      response '502', 'Exchange rate fetch failed' do
        let(:user) { User.create!(name: 'John Doe', email: 'john@example.com') }

        let(:conversion) do
          {
            user_id: user.id,
            from_currency: 'USD',
            to_currency: 'BRL',
            amount: 100.0
          }
        end

        before do
          stub_request(:get, /currencyapi.com/).to_return(status: 500)
        end

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Could not fetch exchange rate' }
               }

        run_test!
      end
    end
  end
end
