class AddIndexToGradingLevelNameColumn < ActiveRecord::Migration[7.0]
  def change
    add_index :grading_levels, :name, unique: true
  end
end
