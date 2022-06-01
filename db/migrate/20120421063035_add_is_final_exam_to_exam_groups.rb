class AddIsFinalExamToExamGroups < ActiveRecord::Migration[7.0]
  def self.up
    add_column :exam_groups, :is_final_exam, :boolean, null: false, default: false
  end

  def self.down
    remove_column :exam_groups, :is_final_exam
  end
end
