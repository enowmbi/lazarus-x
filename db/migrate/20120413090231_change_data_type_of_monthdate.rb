class ChangeDataTypeOfMonthdate < ActiveRecord::Migration[7.0]
  def self.up
    #    remove_column :attendances, :monthdate
    add_column :attendances, :month_date, :date
  end

  def self.down
    remove_column :attendances, :month_date
    #    add_column :attendances, :monthdate,:integer
  end
end
