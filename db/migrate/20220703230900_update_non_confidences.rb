class UpdateNonConfidences < ActiveRecord::Migration[7.0]
  def change
    add_column :non_confidences, :position_id, :integer
  end
end
