class ConversionsController < ApplicationController
  def create
    user = User.find_by(id: params[:user_id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    from_currency = params[:from_currency].upcase
    to_currency = params[:to_currency].upcase
    amount = params[:amount].to_f

    unless valid_currency?(from_currency) && valid_currency?(to_currency)
      return render json: { error: 'Invalid currency code' }, status: :unprocessable_entity
    end

    rate = CurrencyApi.get_rate(from_currency, to_currency)

    return render json: { error: 'Could not fetch exchange rate' }, status: :bad_gateway if rate.nil?

    to_value = (amount * rate).round(4)

    transaction = Transaction.create!(
      user: user,
      from_currency: from_currency,
      to_currency: to_currency,
      from_value: amount,
      to_value: to_value,
      rate: rate
    )

    render json: {
      transaction_id: transaction.id,
      user_id: transaction.user_id,
      from_currency: transaction.from_currency,
      to_currency: transaction.to_currency,
      from_value: transaction.from_value,
      to_value: transaction.to_value,
      rate: transaction.rate
    }, status: :created
  end

  private

  def valid_currency?(code)
    %w[BRL USD EUR JPY].include?(code)
  end
end
