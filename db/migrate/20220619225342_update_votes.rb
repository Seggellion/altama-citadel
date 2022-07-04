class UpdateVotes < ActiveRecord::Migration[7.0]
  def change
    add_column :votes, :non_confidence_id, :integer
  end
end
