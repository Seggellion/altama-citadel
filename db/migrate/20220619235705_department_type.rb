class DepartmentType < ActiveRecord::Migration[7.0]
  def change
    add_column :departments, :department_type, :string
    add_column :departments, :order, :integer
  end
end
