class ImportTitmcStockUnitJob < ApplicationJob
  queue_as :titmc_stock

  def perform(stock_unit_id)
    @stock_unit = StockUnit.find stock_unit_id

    call_operation
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error $ERROR_INFO.message
  end

  private

  def call_operation
    operation = nil
    ActiveRecord::Base.transaction do
      operation = DataSource::Stock::TribunalInstance::Unit::Operation::Load
        .call(stock_unit: @stock_unit)

      if operation.success?
        @stock_unit.update(status: 'COMPLETED')
      else
        raise ActiveRecord::Rollback
      end
    end

    @stock_unit.update(status: 'ERROR') if operation.failure?
  end
end
