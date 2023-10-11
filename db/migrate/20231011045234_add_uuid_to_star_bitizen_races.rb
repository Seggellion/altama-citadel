class AddUuidToStarBitizenRaces < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' # This is needed for PostgreSQL's gen_random_uuid() function.

    # Add a new UUID column and ensure it auto-populates with unique UUIDs for new records.
    add_column :star_bitizen_races, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false

    # Optionally, add an index to the UUID column if you're planning to query by it frequently.
    add_index :star_bitizen_races, :uuid, unique: true
  end
end
