class AddIndexOnNameColumnOfStudentAdditionalFieldTable < ActiveRecord::Migration[7.0]
  def change
    add_index :student_additional_fields, :name, unique: true
  end
end
