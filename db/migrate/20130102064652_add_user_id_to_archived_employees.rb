class AddUserIdToArchivedEmployees < ActiveRecord::Migration[7.0]
  def self.up
    add_column :archived_employees, :user_id, :integer
  end

  def self.down
    remove_column :archived_employees, :user_id
  end
end
