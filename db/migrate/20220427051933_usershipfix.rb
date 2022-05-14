class Usershipfix < ActiveRecord::Migration[7.0]
  def change
    add_column :userships, :ship_serial, :string
    add_column :userships, :pledge_id, :integer
    add_column :userships, :pledge_name, :string
    add_column :userships, :pledge_date, :date
    add_column :userships, :pledge_cost, :string
    add_column :userships, :lti, :boolean
    add_column :userships, :warbond, :boolean
  end
end
