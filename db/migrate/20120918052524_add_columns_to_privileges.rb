class AddColumnsToPrivileges < ActiveRecord::Migration[7.0]
  def self.up
    add_column :privileges, :privilege_tag_id, :int
    add_column :privileges, :priority, :int
  end

  def self.down
    remove_column :privileges, :privilege_tag_id
    remove_column :privileges, :priority
  end
end
