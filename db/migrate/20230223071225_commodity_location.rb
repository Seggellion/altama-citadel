class CommodityLocation < ActiveRecord::Migration[7.0]
  def change
    add_column :commodities, :location_id, :integer
    add_column :rfas, :accepted_time, :datetime
    add_column :rfas, :status_change_time, :datetime
    add_column :rfas, :prescheduled_date, :datetime
  end
end
