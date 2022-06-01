class ChangeArchivedEmployee < ActiveRecord::Migration[7.0]
  def self.up
    change_column :archived_employees, :gender, :string
  end

  def self.down
  #change_column :employees, :gender, :boolean
  end
end
