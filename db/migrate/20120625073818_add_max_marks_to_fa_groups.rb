class AddMaxMarksToFaGroups < ActiveRecord::Migration[7.0]
  def self.up
    add_column :fa_groups, :max_marks, :float, default: 100.0
  end

  def self.down
    remove_column :fa_groups, :max_marks
  end
end
