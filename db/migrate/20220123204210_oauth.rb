class Oauth < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string
    add_column :users, :user_type, :integer
    add_column :users, :profile_image, :string
    add_column :users, :provider, :string
    add_column :users, :uid, :string
  end
end
