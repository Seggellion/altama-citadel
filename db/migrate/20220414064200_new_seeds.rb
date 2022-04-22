class NewSeeds < ActiveRecord::Migration[7.0]
  def change
    add_column :ships, :mass, :float
    remove_column :ships, :weight
    remove_column :ships, :fuel
    remove_column :ships, :quantum
    add_column :ships, :type, :string
    add_column :ships, :career, :string
    add_column :ships, :role, :string
    add_column :ships, :size, :integer
    add_column :ships, :hp, :integer
    add_column :ships, :speed, :integer
    add_column :ships, :afterburner_speed, :integer
    add_column :ships, :ifcs_pitch_max, :integer
    add_column :ships, :ifcs_yaw_max, :integer
    add_column :ships, :ifcs_roll_max, :integer
    add_column :ships, :shield_face_type, :string
    add_column :ships, :armor_physical_dmg_reduction, :integer
    add_column :ships, :armor_energy_dmg_reduction, :integer
    add_column :ships, :armor_distortion_dmg_reduction, :integer
    add_column :ships, :armor_em_signal_reduction, :integer
    add_column :ships, :armor_ir_signal_reduction, :integer
    add_column :ships, :armor_cs_signal_reduction, :integer
    add_column :ships, :capacitor_crew_load, :integer
    add_column :ships, :capacitor_crew_regen, :integer
    add_column :ships, :capacitor_turret_load, :integer
    add_column :ships, :capacitor_turret_regen, :integer
    

  end
end
