class RfaOnline < ActiveRecord::Migration[7.0]
  def change

    add_column :rfas, :users_online, :boolean
    add_column :users, :online_status, :string
    rename_column :rfas, :description, :last_message

  end
end
