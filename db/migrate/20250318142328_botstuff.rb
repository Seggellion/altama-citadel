class Botstuff < ActiveRecord::Migration[7.0]
  def change
    add_column :bots, :announcement_interval, :integer
    add_column :bots, :announcement, :string
  end
end
