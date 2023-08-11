class AslGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :friendships, :group, :string
  end
end
