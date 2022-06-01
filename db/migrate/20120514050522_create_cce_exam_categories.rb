class CreateCceExamCategories < ActiveRecord::Migration[7.0]
  def self.up
    create_table :cce_exam_categories do |t|
      t.string      :name
      t.string      :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :cce_exam_categories
  end
end
