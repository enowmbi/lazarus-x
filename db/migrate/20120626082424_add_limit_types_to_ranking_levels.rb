class AddLimitTypesToRankingLevels < ActiveRecord::Migration[7.0]
  def self.up
	add_column :ranking_levels, :subject_limit_type, :string
	add_column :ranking_levels, :marks_limit_type, :string
	remove_column :ranking_levels, :lower_limit
  end

  def self.down
	remove_column :ranking_levels, :subject_limit_type
	remove_column :ranking_levels, :marks_limit_type
	add_column :ranking_levels, :lower_limit, :boolean 
  end
end
