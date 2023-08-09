class UserFriends < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :asl_number, :integer
    add_index :users, :asl_number, unique: true
    change_column_default :trade_sessions, :session_users, nil

    create_table :friendships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: { to_table: :users }
      t.string :status

      t.timestamps
    end

  end
end
