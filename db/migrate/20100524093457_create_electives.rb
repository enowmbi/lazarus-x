class CreateElectives < ActiveRecord::Migration[7.0]
  def self.up
    create_table :electives do |t|
      t.references :elective_group
      t.timestamps
    end
  end

  def self.down
    drop_table :electives
  end
end
