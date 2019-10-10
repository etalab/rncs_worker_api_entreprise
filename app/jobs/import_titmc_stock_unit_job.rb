class ImportTitmcStockUnitJob < ApplicationJob
  queue_as :titmc_stock

  def perform(stock_unit_id, logger = nil)
    @stock_unit = StockUnit.find(stock_unit_id)
    @stock_unit.update(status: 'LOADING')

    @logger = logger || @stock_unit.logger_for_import

    call_operation
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error($ERROR_INFO.message)
  end

  private

  def call_operation
    operation = nil
    ActiveRecord::Base.transaction do
      operation = TribunalInstance::Stock::Unit::Operation::Load
        .call(stock_unit: @stock_unit, logger: @logger)

      raise(ActiveRecord::Rollback) unless operation.success?

      @stock_unit.update(status: 'COMPLETED')
      TribunalInstance::Stock::Operation::PostImport
        .call(stock_unit: @stock_unit, logger: @logger)
    end

    @stock_unit.update(status: 'ERROR') if operation.failure?
  end
end
