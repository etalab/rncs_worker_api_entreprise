class RenameReferenceDailyUpdateUnit < ActiveRecord::Migration[5.2]
  def change
    rename_column :daily_update_units, :code_greffe, :reference
  end
end
