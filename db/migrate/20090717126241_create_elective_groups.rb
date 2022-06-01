class CreateElectiveGroups < ActiveRecord::Migration[7.0]
  def self.up
    create_table :elective_groups do |t|
      t.string     :name
      t.references :batch
      t.boolean    :is_deleted, default: false
      t.timestamps
    end
  end

  def self.down
    drop_table :elective_groups
  end
end
