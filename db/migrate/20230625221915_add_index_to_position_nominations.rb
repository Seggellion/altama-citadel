class AddIndexToPositionNominations < ActiveRecord::Migration[7.0]
  def change
    add_index :position_nominations, [:nominator_id, :position_id], unique: true
  end
end
