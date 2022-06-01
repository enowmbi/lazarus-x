class AddCourseIdToClassDesignations < ActiveRecord::Migration[7.0]
  def self.up
    add_column :class_designations, :course_id, :integer
  end

  def self.down
    remove_column :class_designations, :course_id
  end
end
