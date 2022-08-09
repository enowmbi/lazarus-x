class ChangeTablename < ActiveRecord::Migration[7.0]
  def change
    rename_table :fa_criterias, :fa_criteria
  end
end
