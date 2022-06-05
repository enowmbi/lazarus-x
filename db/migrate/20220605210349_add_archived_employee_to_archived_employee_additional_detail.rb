class AddArchivedEmployeeToArchivedEmployeeAdditionalDetail < ActiveRecord::Migration[7.0]
  def change
    add_column :archived_employee_additional_details, :archived_employee_id, :bigint
    add_index :archived_employee_additional_details, :archived_employee_id, name: "archived_emp_additional_details_employee"
  end
end
