class ImportTCStockUnitJob < ApplicationJob
  queue_as :tc_stock

  attr_reader :unit

  # TODO: should be refactored to remove Rubocop warnings
  # rubocop:disable Metrics/AbcSize
  def perform(stock_unit_id)
    import = nil
    @unit = StockUnit.find(stock_unit_id)
    # TODO: Move state update into the underlying operation ??!
    # stock_unit.update(status: 'LOADING')

    wrap_import_with_log_level(:fatal) do
      import = TribunalCommerce::StockUnit::Operation::Load
        .call(stock_unit: unit, logger: unit.logger_for_import)

      raise(ActiveRecord::Rollback) if import.failure?
    end

    if import.success?
      unit.update(status: 'COMPLETED')
      TribunalCommerce::Stock::Operation::PostImport
        .call(stock_unit: unit)
    else
      unit.update(status: 'ERROR')
    end
  end
  # rubocop:enable Metrics/AbcSize

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
