class CreateEmployeeCategories < ActiveRecord::Migration[7.0]
  def self.up
    create_table :employee_categories do |t|
      t.string :name
      t.string :prefix
      t.boolean :status
    end
  end

  def self.down
    drop_table :employee_categories
  end

end
