class UsershipStats < ActiveRecord::Migration[7.0]
  def change
    add_column :userships, :health, :integer, default: 100
    add_column :userships, :topspeed, :integer
    add_column :userships, :dexterity, :integer
  end
end
