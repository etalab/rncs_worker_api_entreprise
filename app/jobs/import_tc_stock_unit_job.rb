class ImportTcStockUnitJob < ApplicationJob
  queue_as :tc_stock

  def perform(stock_unit_id)
    # See if disabling ActiveRecord cache free the sidekiq process memory
    ActiveRecord::Base.uncached do
      stock_unit = StockUnit.find(stock_unit_id)

      # TODO ?? pass entire stock unit record to the operation
      DataSource::Stock::TribunalCommerce::Unit::Operation::Load
        .call(stock_unit_path: stock_unit.file_path, code_greffe: stock_unit.code_greffe)
    end
  end
end
