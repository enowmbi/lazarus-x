class AddWeightageToGroupedExams < ActiveRecord::Migration[7.0]
  def self.up
    add_column :grouped_exams, :weightage, :decimal, :precision=>15, :scale=>2
  end

  def self.down
    remove_column :grouped_exams, :weightage
  end
end
