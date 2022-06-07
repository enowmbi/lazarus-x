class AddUniqueIndicesToEmployeeCategory < ActiveRecord::Migration[7.0]
  def change
    add_index :employee_categories, :name, unique: true
    add_index :employee_categories, :prefix, unique: true
  end
end
