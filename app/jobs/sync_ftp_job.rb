require 'open3'

class SyncFTPJob < ActiveJob::Base
  queue_as :auto_updates

  def perform(*_)
    if Rails.env.production?
      sync_files
      ensure_permissions_are_correct
    end
  end

  private

  def ensure_permissions_are_correct
    _stdout, stderr, status = Open3.capture3 "find #{rncs_source_path} -type d -exec chmod 755 {} +"
    Rails.logger.error "Ensure permissions for directories failed with #{stderr}" unless status.success?

    _stdout, stderr, status = Open3.capture3 "find #{rncs_source_path} -type f -exec chmod 644 {} +"
    Rails.logger.error "Ensure permissions for files failed with #{stderr}" unless status.success?
  end

  def sync_files
    _stdout, stderr, status = Open3.capture3 lftp_command
    Rails.logger.error "LFTP sync failed with: #{stderr}" unless status.success?
  end

  def lftp_command
    "lftp -u '#{ftp_login}','#{ftp_password}' -p 21 opendata-rncs.inpi.fr -e 'mirror -c -P 4 --only-missing public/IMR_Donnees_Saisies #{rncs_source_path}; quit'"
  end

  def rncs_source_path
    Rails.configuration.rncs_sources['path']
  end

  def ftp_login
    @ftp_login ||= Rails.application.credentials.ftp_login
  end

  def ftp_password
    @ftp_password ||= Rails.application.credentials.ftp_password
  end
end
