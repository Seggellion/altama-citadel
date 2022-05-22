class UpdateUserPositionHistoriesTable < ActiveRecord::Migration[7.0]
  def change
    add_column :user_position_histories, :active, :boolean
  end
end
