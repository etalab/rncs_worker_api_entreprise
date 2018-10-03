class RenameDaylyToDaily < ActiveRecord::Migration[5.2]
  def change
    rename_table :dayly_updates, :daily_updates
    rename_table :dayly_update_units, :daily_update_units
    rename_column :daily_update_units, :dayly_update_id, :daily_update_id
  end
end
