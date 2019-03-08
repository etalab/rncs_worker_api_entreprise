class SyncFTPJob < ActiveJob::Base
  queue_as :auto_updates

  def perform(*args)
    Rails.logger.info 'Sync files from FTP...'
  end
end
