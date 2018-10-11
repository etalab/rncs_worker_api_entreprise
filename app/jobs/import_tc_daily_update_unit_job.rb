class ImportTcDailyUpdateUnitJob < ApplicationJob
  queue_as :tc_daily_update

  def perform(daily_update_id)
    unit = DailyUpdateUnit.find(daily_update_id)
    import = TribunalCommerce::DailyUpdateUnit::Operation::Load
      .call(daily_update_unit: unit)

    if import.success?
      unit.update(status: 'COMPLETED')
      TribunalCommerce::DailyUpdateUnit::Operation::PostImport.call

    else
      unit.update(status: 'ERROR')
    end
  end
end
