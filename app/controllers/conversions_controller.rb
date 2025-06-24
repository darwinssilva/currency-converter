class ConversionsController < ApplicationController
  def create
    result = ConversionProcessor.new(
      user_id: params[:user_id],
      from_currency: params[:from_currency],
      to_currency: params[:to_currency],
      amount: params[:amount]
    ).call

    if result[:success]
      render json: result[:data], status: result[:status]
    else
      render json: { error: result[:error] }, status: result[:status]
    end
  end
end
