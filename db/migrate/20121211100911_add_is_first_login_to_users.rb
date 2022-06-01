class AddIsFirstLoginToUsers < ActiveRecord::Migration[7.0]
  def self.up
    add_column :users, :is_first_login, :boolean
  end

  def self.down
    remove_column :users, :is_first_login
  end
end
