class AddIndexToStudentData < ActiveRecord::Migration[7.0]
  def self.up
    add_index :students, %i[nationality_id immediate_contact_id student_category_id], name: "student_data_index"
    # add_index :student_additional_details, [:student_id,:additional_field_id], :name => "student_data_index"
  end

  def self.down
    remove_index :students, name: "student_data_index"
    # remove_index :student_additional_details, :name => "student_data_index"
  end
end
