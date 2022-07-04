class UpdateNonConfidencesTable < ActiveRecord::Migration[7.0]
  def change
    add_column :non_confidences, :position_user_id, :integer
  end
end
