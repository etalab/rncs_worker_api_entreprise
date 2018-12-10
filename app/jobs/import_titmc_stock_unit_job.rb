class ImportTitmcStockUnitJob < ApplicationJob
  queue_as :titmc_stock

  def perform(stock_unit_id)
  end
end
