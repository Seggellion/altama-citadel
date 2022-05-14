class CrusaderCode < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :staff_code, :string
  end
end
