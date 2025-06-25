# spec/integration/transactions_spec.rb
require 'swagger_helper'

RSpec.describe 'Transactions API', type: :request do
  path '/transactions' do
    get 'List transactions by user' do
      tags 'Transactions'
      produces 'application/json'
      parameter name: :user_id, in: :query, type: :integer, required: true, description: 'ID of the user'

      response '200', 'transactions listed' do
        let(:user) { User.create!(name: 'Jane Doe', email: 'jane@example.com') }

        before do
          Transaction.create!(
            user: user,
            from_currency: 'USD',
            to_currency: 'BRL',
            from_value: 100.0,
            to_value: 525.0,
            rate: 5.25
          )
        end

        let(:user_id) { user.id }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   user_id: { type: :integer },
                   from_currency: { type: :string },
                   to_currency: { type: :string },
                   from_value: { type: :number },
                   to_value: { type: :number },
                   rate: { type: :number }
                 },
                 required: %w[
                   id user_id from_currency to_currency
                   from_value to_value rate created_at updated_at
                 ]
               }

        run_test!
      end

      response '400', 'missing user_id parameter' do
        let(:user_id) { nil }
        run_test!
      end
    end
  end
end
