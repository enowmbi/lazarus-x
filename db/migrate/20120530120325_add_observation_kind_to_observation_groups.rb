class AddObservationKindToObservationGroups < ActiveRecord::Migration[7.0]
  def self.up
    add_column :observation_groups, :observation_kind, :string
  end

  def self.down
    remove_column :observation_groups, :observation_kind
  end
end
