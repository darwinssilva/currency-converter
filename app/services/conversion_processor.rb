class ConversionProcessor
  SUPPORTED_CURRENCIES = %w[BRL USD EUR JPY].freeze

  def initialize(user_id:, from_currency:, to_currency:, amount:)
    @user_id = user_id
    @from_currency = from_currency&.upcase
    @to_currency = to_currency&.upcase
    @amount = amount.to_f
  end

  def call
    return error('User not found', :not_found) unless user
    return error('Invalid currency code', :unprocessable_entity) unless valid_currencies?

    rate = CurrencyApi.get_rate(@from_currency, @to_currency)
    return error('Could not fetch exchange rate', :bad_gateway) if rate.nil?

    to_value = (@amount * rate).round(4)

    transaction = Transaction.create!(
      user: user,
      from_currency: @from_currency,
      to_currency: @to_currency,
      from_value: @amount,
      to_value: to_value,
      rate: rate
    )

    success(transaction)
  end

  private

  def user
    @user ||= User.find_by(id: @user_id)
  end

  def valid_currencies?
    SUPPORTED_CURRENCIES.include?(@from_currency) &&
      SUPPORTED_CURRENCIES.include?(@to_currency)
  end

  def success(transaction)
    {
      success: true,
      status: :created,
      data: {
        transaction_id: transaction.id,
        user_id: transaction.user_id,
        from_currency: transaction.from_currency,
        to_currency: transaction.to_currency,
        from_value: transaction.from_value,
        to_value: transaction.to_value,
        rate: transaction.rate
      }
    }
  end

  def error(message, status)
    { success: false, status: status, error: message }
  end
end
