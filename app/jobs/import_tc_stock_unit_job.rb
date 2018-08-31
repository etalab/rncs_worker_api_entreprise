class ImportTcStockUnitJob < ApplicationJob
  queue_as :tc_stock

  def perform(path:, **)
    DataSource::Stock::TribunalCommerce::Unit::Operation::Load.call(stock_unit_path: path)
  end
end
