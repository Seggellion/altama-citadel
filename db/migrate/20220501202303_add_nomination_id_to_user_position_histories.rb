class AddNominationIdToUserPositionHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :user_position_histories, :nomination_id, :integer
  end
end
