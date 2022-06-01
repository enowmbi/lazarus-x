class AddFormerToArchivedEmployee < ActiveRecord::Migration[7.0]
  def self.up
    add_column :archived_employees, :former_id, :string
  end

  def self.down
    remove_column :archived_employees, :former_id
  end
end
