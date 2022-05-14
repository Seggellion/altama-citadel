class AddNominationIdToUserPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :user_positions, :nomination_id, :integer
  end
end
