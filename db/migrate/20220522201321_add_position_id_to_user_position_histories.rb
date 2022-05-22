class AddPositionIdToUserPositionHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :user_position_histories, :position_id, :integer
  end
end
