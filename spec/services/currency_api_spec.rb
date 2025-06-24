require 'rails_helper'

RSpec.describe CurrencyApi do
  describe '.get_rate' do
    let(:from_currency) { 'USD' }
    let(:to_currency) { 'BRL' }

    context 'when API returns success' do
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

      it 'returns the correct rate' do
        rate = described_class.get_rate(from_currency, to_currency)
        expect(rate).to eq(5.25)
      end
    end

    context 'when API returns an error' do
      before do
        stub_request(:get, /currencyapi.com/)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'returns nil' do
        rate = described_class.get_rate(from_currency, to_currency)
        expect(rate).to be_nil
      end
    end

    context 'when an exception is raised' do
      before do
        allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("boom"))
      end

      it 'returns nil and logs the error' do
        expect(Rails.logger).to receive(:error).with(/Currency API error: boom/)
        rate = described_class.get_rate(from_currency, to_currency)
        expect(rate).to be_nil
      end
    end
  end
end
