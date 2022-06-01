class CreateBatchStudentsJoinTable < ActiveRecord::Migration[7.0]
  def self.up
    create_table :batch_students, :id => false do |t|
      t.references :student
      t.references :batch
    end
  end

  def self.down
    drop_table :batch_students
  end

end
