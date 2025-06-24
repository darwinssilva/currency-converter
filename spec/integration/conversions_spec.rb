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
          user_id: { type: :integer },
          from_currency: { type: :string },
          to_currency: { type: :string },
          amount: { type: :number }
        },
        required: %w[user_id from_currency to_currency amount]
      }

      response '201', 'conversion successful' do
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
          stub_request(:get, /currencyapi.com/)
            .to_return(
              status: 200,
              body: {
                data: {
                  'BRL' => { 'value' => 5.25 }
                }
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        run_test!
      end

      response '404', 'user not found' do
        let(:conversion) do
          {
            user_id: 99_999,
            from_currency: 'USD',
            to_currency: 'BRL',
            amount: 100.0
          }
        end

        before do
          stub_request(:get, /currencyapi.com/)
            .to_return(
              status: 200,
              body: {
                data: {
                  'BRL' => { 'value' => 5.25 }
                }
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        run_test!
      end
    end
  end
end
