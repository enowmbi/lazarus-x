class AddIsDeletedToWeekdaysAndClassTiming < ActiveRecord::Migration[7.0]
  def self.up
    add_column :weekdays, :is_deleted, :boolean, :default=> false
    add_column :class_timings, :is_deleted, :boolean, :default =>false
  end

  def self.down
    remove_column :weekdays, :is_deleted
    remove_column :class_timings, :is_deleted
  end
end
