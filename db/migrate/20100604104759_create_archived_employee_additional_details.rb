class CreateArchivedEmployeeAdditionalDetails < ActiveRecord::Migration[7.0]
  def self.up
    create_table :archived_employee_additional_details do |t|
      t.references :employee, index: { name: "archived_emp_additional_details_employee" }
      t.references :additional_field, index: { name: "archived_emp_additional_details_additional_field" }
      t.string     :additional_info
    end
  end

  def self.down
    drop_table :archived_employee_additional_details
  end
end
