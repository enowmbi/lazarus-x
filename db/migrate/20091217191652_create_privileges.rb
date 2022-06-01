class CreatePrivileges < ActiveRecord::Migration[7.0]
  def self.up
    create_table :privileges do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :privileges
  end
end
