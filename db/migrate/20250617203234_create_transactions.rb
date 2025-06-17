class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :from_currency
      t.string :to_currency
      t.float :from_value
      t.float :to_value
      t.float :rate

      t.timestamps
    end
  end
end
