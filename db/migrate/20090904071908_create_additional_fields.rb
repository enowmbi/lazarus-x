class CreateAdditionalFields < ActiveRecord::Migration[7.0]
  def self.up
    create_table :additional_fields do |t|
      t.string :name
      t.boolean :status
    end
  end

  def self.down
    drop_table :additional_fields
  end
end
