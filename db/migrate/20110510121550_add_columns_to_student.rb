class AddColumnsToStudent < ActiveRecord::Migration[7.0]
  def self.up
    add_column    :archived_students, :photo_file_size, :integer
    rename_column :archived_students, :photo_filename, :photo_file_name
    add_column    :students, :photo_file_size, :integer
    rename_column :students, :photo_filename, :photo_file_name
  end

  def self.down
    remove_column :students, :photo_file_size
    rename_column :students, :photo_file_name, :photo_filename
    remove_column :archived_students, :photo_file_size
    rename_column :archived_students, :photo_file_name, :photo_filename
  end
end
