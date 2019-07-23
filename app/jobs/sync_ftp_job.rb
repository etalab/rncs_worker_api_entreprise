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
    _stdout, stderr, status = Open3.capture3 "find #{rncs_sources_path} -type d -exec chmod 755 {} +"
    Rails.logger.error "Ensure permissions for directories failed with #{stderr}" unless status.success?

    _stdout, stderr, status = Open3.capture3 "find #{rncs_sources_path} -type f -exec chmod 644 {} +"
    Rails.logger.error "Ensure permissions for files failed with #{stderr}" unless status.success?
  end

  def sync_files
    _stdout, stderr, status = Open3.capture3 wget_command
    Rails.logger.error "WGET sync failed with: #{stderr}" unless status.success?
  end

  def wget_command
    <<-ENDWGET
    wget -r --level=8 -m --reject "index.html" -c -N --secure-protocol=auto --no-proxy --ftp-user=#{ftp_login} --ftp-password=#{ftp_password} --directory-prefix=#{rncs_dir_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/flux/#{current_year}/#{current_month};
    wget -r --level=8 -m --reject "index.html" -c -N --secure-protocol=auto --no-proxy --ftp-user=#{ftp_login} --ftp-password=#{ftp_password} --directory-prefix=#{rncs_dir_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/flux/#{year_of_previous_month}/#{previous_month};
    wget -r --level=8 -m --reject "index.html" -c -N --secure-protocol=auto --no-proxy --ftp-user=#{ftp_login} --ftp-password=#{ftp_password} --directory-prefix=#{rncs_dir_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/stock/#{current_year}/#{current_month};
    wget -r --level=8 -m --reject "index.html" -c -N --secure-protocol=auto --no-proxy --ftp-user=#{ftp_login} --ftp-password=#{ftp_password} --directory-prefix=#{rncs_dir_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/stock/#{year_of_previous_month}/#{previous_month}
    ENDWGET
  end

  def rncs_dir_prefix
    Rails.configuration.rncs_sources['path_prefix']
  end

  def rncs_sources_path
    Rails.configuration.rncs_sources_path
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

  def year_of_previous_month
    @previous_month_year ||= (Time.now.beginning_of_month - 1.day).strftime("%Y")
  end

  def previous_month
    @previous_month ||= (Time.now.beginning_of_month - 1.day).strftime("%m")
  end

  def clean_sync_folders
    sync_folders = [
      "#{rncs_sources_path}/tc/flux/#{current_year}",
      "#{rncs_sources_path}/tc/flux/#{year_of_previous_month}",
      "#{rncs_sources_path}/tc/stock/#{current_year}",
      "#{rncs_sources_path}/tc/stock/#{year_of_previous_month}",
    ]

    sync_folders.each do |dir|
      FileUtils.rm_rf(dir) if Dir.exists?(dir) && Dir.empty?(dir)
    end
  end
end
