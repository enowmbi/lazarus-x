class CreateSubjectAmounts < ActiveRecord::Migration[7.0]
  def self.up
    create_table :subject_amounts do |t|
      t.references :course
      t.decimal :amount
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :subject_amounts
  end
end
