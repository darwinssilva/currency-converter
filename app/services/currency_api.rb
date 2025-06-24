require 'net/http'
require 'uri'
require 'json'

class CurrencyApi
  BASE_URL = "https://api.currencyapi.com/v3/latest"
  API_KEY = ENV['CURRENCY_API_KEY']

  def self.get_rate(from, to)
    uri = URI("#{BASE_URL}?apikey=#{API_KEY}&base_currency=#{from}&currencies=#{to}")
    response = Net::HTTP.get_response(uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data.dig("data", to, "value").to_f
  rescue => e
    Rails.logger.error("Currency API error: #{e.message}")
    nil
  end
end
