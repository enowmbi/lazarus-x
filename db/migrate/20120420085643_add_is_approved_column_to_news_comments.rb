class AddIsApprovedColumnToNewsComments < ActiveRecord::Migration[7.0]
  def self.up
    add_column :news_comments, :is_approved, :boolean, :default => 0
  end

  def self.down
    remove_column :news_comments, :is_approved
  end
end
