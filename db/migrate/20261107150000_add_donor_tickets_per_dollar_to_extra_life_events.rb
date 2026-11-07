# Optional amount-weighted donor tickets per Extra Life event (owner decision 2026-11-07). Additive: the column is
# nullable and NULL keeps the flat one-donor-ticket rule, so existing events behave exactly as before until an admin
# sets a value. Loads extra_life_pool version 2 (db/sql/extra_life_giveaways_v2.sql).
class AddDonorTicketsPerDollarToExtraLifeEvents < ActiveRecord::Migration[7.0]
  def up
    add_column :extra_life_events, :donor_tickets_per_dollar, :integer
    add_check_constraint :extra_life_events,
                         "donor_tickets_per_dollar IS NULL OR donor_tickets_per_dollar BETWEEN 0 AND 1000",
                         name: "extra_life_events_donor_tickets_per_dollar_range"
    execute File.read(Rails.root.join("db/sql/extra_life_giveaways_v2.sql"))
  end

  def down
    execute File.read(Rails.root.join("db/sql/extra_life_giveaways_v1.sql"))
    remove_check_constraint :extra_life_events, name: "extra_life_events_donor_tickets_per_dollar_range"
    remove_column :extra_life_events, :donor_tickets_per_dollar
  end
end
