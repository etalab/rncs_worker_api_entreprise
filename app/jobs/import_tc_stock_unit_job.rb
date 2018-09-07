class ImportTcStockUnitJob < ApplicationJob
  queue_as :tc_stock

  def perform(path:, code_greffe:, **)
    # See if disabling ActiveRecord cache free the sidekiq process memory
    ActiveRecord::Base.uncached do
      DataSource::Stock::TribunalCommerce::Unit::Operation::Load
        .call(stock_unit_path: path, code_greffe: code_greffe)
    end
  end
end
