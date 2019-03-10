class ImportTitmcDailyUpdateUnitJob < ApplicationJob
  queue_as :titmc_daily_update

  def perform(daily_update_unit_id, logger = nil)
    @unit = DailyUpdateUnit.find daily_update_unit_id
    @unit.update status: 'LOADING'

    @logger = logger || @unit.logger_for_import

    call_operation
    post_transaction
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error $ERROR_INFO.message
  end

  private

  def call_operation
    ActiveRecord::Base.transaction do
      @operation = TribunalInstance::DailyUpdate::Unit::Operation::Load
        .call(daily_update_unit: @unit, logger: @logger)

      if @operation.success?
        @unit.update status: 'COMPLETED'
      else
        raise ActiveRecord::Rollback
      end
    end
  end

  def post_transaction
    if @operation.success?
      import_next_daily_update if daily_update_completed?
    else
      @unit.update status: 'ERROR'
    end
  end

  def import_next_daily_update
    TribunalInstance::DailyUpdate::Operation::Import
      .call logger: @logger
  end

  def daily_update_completed?
    @unit.daily_update.status == 'COMPLETED'
  end
end
