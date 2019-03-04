class ImportTitmcDailyUpdateUnitJob < ApplicationJob
  queue_as :titmc_daily_update

  def perform(daily_update_unit_id, logger = nil)

  end
end
