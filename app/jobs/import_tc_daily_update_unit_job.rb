class ImportTcDailyUpdateUnitJob < ApplicationJob
  queue_as :tc_daily_update

  def perform(daily_update_id)
    import = nil
    unit = DailyUpdateUnit.find(daily_update_id)
    ActiveRecord::Base.transaction do
      import = TribunalCommerce::DailyUpdateUnit::Operation::Load
        .call(daily_update_unit: unit)

      if import.success?
        unit.update(status: 'COMPLETED')
      else
        raise ActiveRecord::Rollback
      end
    end

    # Checking the import result a second time outside the transaction
    # so the 'ERROR' status is persisted into DB and not rollback to 'PENDING'
    if import.success?
      TribunalCommerce::DailyUpdateUnit::Operation::PostImport
        .call(daily_update_unit: unit)
    else
      unit.update(status: 'ERROR')
    end
  end
end
