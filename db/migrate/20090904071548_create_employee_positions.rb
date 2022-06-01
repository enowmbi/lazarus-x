class CreateEmployeePositions < ActiveRecord::Migration[7.0]
  def self.up
    create_table :employee_positions do |t|
      t.string  :name
      t.references :employee_category
      t.boolean :status
    end
  end

  def self.down
    drop_table :employee_positions
  end

end
