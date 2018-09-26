class RenameStockUnitNameToPath < ActiveRecord::Migration[5.2]
  def change
    rename_column :stock_units, :name, :file_path
  end
end
