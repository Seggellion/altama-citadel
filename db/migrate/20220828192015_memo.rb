class Memo < ActiveRecord::Migration[7.0]
  def change
    add_column :tasks, :memo_type, :string
    add_column :tasks, :memo_text, :string
  end
end
