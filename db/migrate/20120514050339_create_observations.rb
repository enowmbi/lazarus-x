class CreateObservations < ActiveRecord::Migration[7.0]
  def self.up
    create_table :observations do |t|
      t.string          :name
      t.string          :desc
      t.boolean         :is_active
      t.integer         :observation_group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :observations
  end
end
