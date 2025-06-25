class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :from_currency, :to_currency, :from_value, :to_value, :rate
end
