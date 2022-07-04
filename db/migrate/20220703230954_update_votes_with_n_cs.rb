class UpdateVotesWithNCs < ActiveRecord::Migration[7.0]
  def change
    add_column :votes, :user_position_id, :integer
  end
end
