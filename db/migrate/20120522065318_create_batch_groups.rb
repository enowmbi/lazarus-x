class CreateBatchGroups < ActiveRecord::Migration[7.0]
  def self.up
    create_table :batch_groups do |t|
      t.integer :course_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :batch_groups
  end
end
