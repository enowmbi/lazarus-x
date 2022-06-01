class AddAmountToSubjects < ActiveRecord::Migration[7.0]
  def self.up
    add_column :subjects, :amount, :decimal, precision: 15, scale: 2
  end

  def self.down
    remove_column :subjects, :amount
  end
end
