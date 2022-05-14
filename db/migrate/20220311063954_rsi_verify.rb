class RsiVerify < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :rsi_verify, :boolean

    ActiveRecord::Base.connection.reset_pk_sequence!('rsi_users')
  end
end
