class ChangeTradesssion < ActiveRecord::Migration[7.0]
  def change
    rename_column :trade_runs, :tradesession_id, :trade_session_id
    rename_column :trade_session_users, :tradesession_id, :trade_session_id
  end
end
