class ImportTcStockUnitJob < ApplicationJob
  queue_as :tc_stock

  def perform(stock_unit_id)
    # See if disabling ActiveRecord cache free the sidekiq process memory
    ActiveRecord::Base.uncached do
      stock_unit = StockUnit.find(stock_unit_id)
      stock_unit.update(status: 'LOADING')

      # TODO ?? pass entire stock unit record to the operation
      import_unit = DataSource::Stock::TribunalCommerce::Unit::Operation::Load
        .call(stock_unit_path: stock_unit.file_path, code_greffe: stock_unit.code_greffe)

      if import_unit.success?
        stock_unit.update(status: 'COMPLETED')
        DataSource::Stock::TribunalCommerce::Operation::PostImport
          .call(stock_unit: stock_unit)
      else
        stock_unit.update(status: 'ERROR')
      end
    end
  end
end
