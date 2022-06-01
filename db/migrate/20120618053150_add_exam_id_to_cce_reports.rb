class AddExamIdToCceReports < ActiveRecord::Migration[7.0]
  def self.up
    add_column :cce_reports, :exam_id, :integer
  end

  def self.down
    remove_column :cce_reports, :exam_id
  end
end
