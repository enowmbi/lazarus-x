class CreateUserEvents < ActiveRecord::Migration[7.0]

  def self.up
    create_table :user_events do |t|
      t.references :event
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :user_events
  end

end
