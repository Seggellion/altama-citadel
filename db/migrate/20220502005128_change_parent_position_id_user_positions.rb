class ChangeParentPositionIdUserPositions < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_positions, :parent_position_id, :position_id
  end
end
