class AddGradingTypeToCourses < ActiveRecord::Migration[7.0]
  def self.up
    add_column :courses, :grading_type, :string
  end

  def self.down
    remove_column :courses, :grading_type
  end
end
