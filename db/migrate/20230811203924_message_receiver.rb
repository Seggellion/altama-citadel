class MessageReceiver < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :receiver_id, :integer
  end
end
