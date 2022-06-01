class AddTimetableIdToTimetableEntries < ActiveRecord::Migration[7.0]
  def self.up
    add_column  :timetable_entries, :timetable_id, :integer
  end

  def self.down
    remove_column  :timetable_entries, :timetable_id
  end
end
