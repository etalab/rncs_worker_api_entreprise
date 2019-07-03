require 'open3'

class SyncFTPJob < ActiveJob::Base
  queue_as :auto_updates

  def perform(*_)
    sync_files
    ensure_permissions_are_correct
    clean_sync_folders
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
    <<-ENDLFTP
    lftp -u '#{ftp_login}','#{ftp_password}' -p 21 opendata-rncs.inpi.fr -e '
      mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/flux/#{current_year}/#{current_month}/ -O #{rncs_source_path}/tc/flux/#{current_year};
      mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/flux/#{previous_month_year}/#{previous_month}/ -O #{rncs_source_path}/tc/flux/#{previous_month_year};
      mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/stock/#{current_year}/#{current_month}/ -O #{rncs_source_path}/tc/stock/#{current_year};
      mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/stock/#{previous_month_year}/#{previous_month}/ -O #{rncs_source_path}/tc/stock/#{previous_month_year};
      quit'
    ENDLFTP
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

  def current_year
    @current_year ||= Time.now.strftime("%Y")
  end

  def current_month
    @current_month ||= Time.now.strftime("%m")
  end

  def previous_month_year
    @previous_month_year ||= (Time.now.beginning_of_month - 1.day).strftime("%Y")
  end

  def previous_month
    @previous_month ||= (Time.now.beginning_of_month - 1.day).strftime("%m")
  end

  def clean_sync_folders
    sync_folders = [
      "#{rncs_source_path}/tc/flux/#{current_year}/#{current_month}",
      "#{rncs_source_path}/tc/flux/#{current_year}",
      "#{rncs_source_path}/tc/flux/#{previous_month_year}/#{previous_month}",
      "#{rncs_source_path}/tc/flux/#{previous_month_year}",
      "#{rncs_source_path}/tc/stock/#{current_year}/#{current_month}",
      "#{rncs_source_path}/tc/stock/#{current_year}",
      "#{rncs_source_path}/tc/stock/#{previous_month_year}/#{previous_month}",
      "#{rncs_source_path}/tc/stock/#{previous_month_year}",
    ]

    sync_folders.each do |dir|
      FileUtils.rm_rf(dir) if Dir.exists?(dir) && Dir.empty?(dir)
    end
  end
end
