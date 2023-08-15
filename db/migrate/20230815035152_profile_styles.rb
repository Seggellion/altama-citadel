class ProfileStyles < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :font_name, :string, default: 'Arial'
    add_column :users, :font_color, :string, default: '#000000' # Default to black
    add_column :users, :accent_color, :string, default: '#000000' # Default to black
    add_column :users, :background_color, :string, default: '#FFFFFF' # Default to white
    add_column :users, :font_size, :integer, default: 14
  end
end
