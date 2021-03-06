class AddCreditPointsToGradingLevels < ActiveRecord::Migration[7.0]
  def self.up
    add_column :grading_levels, :credit_points, :int
    add_column :grading_levels, :description, :string
  end

  def self.down
    remove_column :grading_levels, :description
    remove_column :grading_levels, :credit_points
  end
end
