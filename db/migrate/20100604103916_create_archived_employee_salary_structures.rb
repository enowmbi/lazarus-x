class CreateArchivedEmployeeSalaryStructures < ActiveRecord::Migration[7.0]
  def self.up
    create_table :archived_employee_salary_structures do |t|
      t.references :employee, index: { name: "archived_emp_sal_struct_employee" }
      t.references :payroll_category, index: { name: "archived_emp_sal_struct_payroll_category" }
      t.string     :amount
    end
  end

  def self.down
    drop_table :archived_employee_salary_structures
  end
end
