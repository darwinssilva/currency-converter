class TransactionsController < ApplicationController
  def index
    user = User.find_by(id: params[:user_id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    transactions = Transaction.where(user_id: user.id)

    render json: transactions, each_serializer: TransactionSerializer, status: :ok
  end
end
