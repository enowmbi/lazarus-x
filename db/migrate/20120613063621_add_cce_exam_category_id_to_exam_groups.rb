class AddCceExamCategoryIdToExamGroups < ActiveRecord::Migration[7.0]
  def self.up
    add_column :exam_groups, :cce_exam_category_id, :integer
  end

  def self.down
    remove_column :exam_groups, :cce_exam_category_id
  end
end
