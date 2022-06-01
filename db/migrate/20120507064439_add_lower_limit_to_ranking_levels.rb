class AddLowerLimitToRankingLevels < ActiveRecord::Migration[7.0]
  def self.up
    add_column :ranking_levels, :lower_limit, :boolean, default: false
  end

  def self.down
    remove_column :ranking_levels, :lower_limit
  end
end
