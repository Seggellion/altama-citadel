class TradeSessionUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :trade_sessions, :session_users, :string, default: false
  end
end
