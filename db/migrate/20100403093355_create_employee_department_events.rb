class CreateEmployeeDepartmentEvents < ActiveRecord::Migration[7.0]
  def self.up
    create_table :employee_department_events do |t|
      t.references :event
      t.references :employee_department
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_department_events
  end
end
