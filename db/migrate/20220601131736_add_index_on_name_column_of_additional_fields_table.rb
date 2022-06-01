class AddIndexOnNameColumnOfAdditionalFieldsTable < ActiveRecord::Migration[7.0]
  def change
    add_index :additional_fields, :name, unique: true
  end
end
