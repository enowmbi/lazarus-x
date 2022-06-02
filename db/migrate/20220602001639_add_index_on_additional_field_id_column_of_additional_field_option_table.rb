class AddIndexOnAdditionalFieldIdColumnOfAdditionalFieldOptionTable < ActiveRecord::Migration[7.0]
  def change
    add_index :additional_field_options, :additional_field_id
  end
end
