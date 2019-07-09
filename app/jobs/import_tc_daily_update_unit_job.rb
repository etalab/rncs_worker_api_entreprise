class ImportTcDailyUpdateUnitJob < ApplicationJob
  queue_as :tc_daily_update

  attr_reader :unit

  def perform(daily_update_id)
    import = nil
    @unit = DailyUpdateUnit.find(daily_update_id)

    wrap_import_with_log_level(:fatal) do
      import = unit_importer.call(daily_update_unit: unit, logger: import_logger)

      raise ActiveRecord::Rollback if import.failure?
    end

    # Checking the import result a second time outside the transaction
    # so the 'ERROR' status is persisted into DB and not rollback to 'PENDING'
    if import.success?
      unit.update(status: 'COMPLETED')
      TribunalCommerce::DailyUpdateUnit::Operation::PostImport
        .call(daily_update_unit: unit)
    else
      unit.update(status: 'ERROR')
    end
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
      return TribunalCommerce::PartialStockUnit::Operation::Load
    else
      return TribunalCommerce::DailyUpdateUnit::Operation::Load
    end
  end
end
