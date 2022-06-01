class CreateEmployeeDepartments < ActiveRecord::Migration[7.0]
  def self.up
    create_table :employee_departments do |t|
      t.string  :code
      t.string  :name
      t.boolean :status
    end
  end

  def self.down
    drop_table :employee_departments
  end
end
