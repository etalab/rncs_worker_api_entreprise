class DailyImportTCJob < ApplicationJob
  queue_as :auto_updates

  def perform(*_)
    TribunalCommerce::Operation::DailyImport.call
  end
end
