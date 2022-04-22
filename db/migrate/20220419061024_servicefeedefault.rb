class Servicefeedefault < ActiveRecord::Migration[7.0]
  def change
    change_column :rfas, :servicefee, :float, default: 0.0 
  end
end
