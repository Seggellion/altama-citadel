class AddUsershipIdToRfas < ActiveRecord::Migration[7.0]
  def change
    add_column :rfas, :usership_id, :integer
  end
end
