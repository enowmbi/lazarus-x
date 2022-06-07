class RenameEmployeeIdToArchivedEmployeeId < ActiveRecord::Migration[7.0]
  def change
    remove_column :archived_employee_additional_details, :employee_id
  end
end
