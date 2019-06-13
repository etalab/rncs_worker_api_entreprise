class ImportTcStockUnitJob < ApplicationJob
  queue_as :tc_stock

  def perform(stock_unit_id)
    import_unit = nil
    stock_unit = StockUnit.find(stock_unit_id)
    # TODO Move state update into the underlying operation ??!
    # stock_unit.update(status: 'LOADING')

    wrap_import_with_log_level(:fatal) do
      import_unit = TribunalCommerce::StockUnit::Operation::Load
        .call(stock_unit: stock_unit, logger: stock_unit.logger_for_import)

      if import_unit.success?
        stock_unit.update(status: 'COMPLETED')
      else
        raise ActiveRecord::Rollback
      end
    end

    if import_unit.success?
      TribunalCommerce::Stock::Operation::PostImport
        .call(stock_unit: stock_unit)
    else
      stock_unit.update(status: 'ERROR')
    end
  end

  private

  def wrap_import_with_log_level(log_level)
    usual_log_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = log_level
    ActiveRecord::Base.transaction do
      yield
    end
    ActiveRecord::Base.logger.level = usual_log_level
  end
end
