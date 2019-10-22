class ImportTCDailyUpdateUnitJob < ApplicationJob
  queue_as :tc_daily_update

  attr_reader :unit

  def perform(daily_update_id)
    @import = nil
    @unit = DailyUpdateUnit.find(daily_update_id)

    wrap_import_with_log_level(:fatal) do
      @import = unit_importer.call(daily_update_unit: unit, logger: import_logger)

      fail(ActiveRecord::Rollback) if @import.failure?
    end

    update_unit_status

    TribunalCommerce::DailyUpdateUnit::Operation::PostImport.call(daily_update_unit: unit) if @import.success?
  end

  private

  def import_logger
    unit.logger_for_import
  end

  def wrap_import_with_log_level(log_level)
    usual_log_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = log_level
    ActiveRecord::Base.transaction do
      yield
    end
    ActiveRecord::Base.logger.level = usual_log_level
  end

  def unit_importer
    if unit.daily_update.partial_stock?
      TribunalCommerce::PartialStockUnit::Operation::Load
    else
      TribunalCommerce::DailyUpdateUnit::Operation::Load
    end
  end

  def update_unit_status
    # Checking the import result a second time outside the transaction
    # so the 'ERROR' status is persisted into DB and not rollback to 'PENDING'
    if @import.success?
      unit.update(status: 'COMPLETED')
    else
      unit.update(status: 'ERROR')
    end
  end
end
