class ImportTcDailyUpdateUnitJob < ApplicationJob
  queue_as :tc_daily_update

  def perform(daily_update_id)

  end
end
