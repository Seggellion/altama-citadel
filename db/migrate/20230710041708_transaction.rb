class Transaction < ActiveRecord::Migration[7.0]
  def change

    create_table :transactions do |t|

      t.integer :amount
      t.references :sender, foreign_key: {to_table: :users}
      t.references :receiver, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
