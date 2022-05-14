class ServiceFee < ActiveRecord::Migration[7.0]
  def change
    add_column :rfas, :servicefee, :float
    add_column :users, :background_style, :integer
  end
end
