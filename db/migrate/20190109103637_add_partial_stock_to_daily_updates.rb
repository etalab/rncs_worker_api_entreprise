class AddPartialStockToDailyUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :daily_updates, :partial_stock, :boolean
  end
end
