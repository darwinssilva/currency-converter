FactoryBot.define do
  factory :transaction do
    user { nil }
    from_currency { "MyString" }
    to_currency { "MyString" }
    from_value { 1.5 }
    to_value { 1.5 }
    rate { 1.5 }
  end
end
