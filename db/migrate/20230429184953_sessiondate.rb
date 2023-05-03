class Sessiondate < ActiveRecord::Migration[7.0]
  def change
    add_column :trade_sessions, :session_date, :datetime
  end
end
