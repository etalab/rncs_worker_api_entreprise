class SyncFTPJob < ActiveJob::Base
  queue_as :auto_updates

  attr_reader :ftp_login, :ftp_password

  def perform(*args)
    @ftp_login = Rails.application.credentials.ftp_login
    @ftp_password = Rails.application.credentials.ftp_password

    # Sync FTP files
    `lftp -u '#{ftp_login}','#{ftp_password}' -p 21 opendata-rncs.inpi.fr -e 'mirror -c -P 4 --only-missing public/IMR_Donnees_Saisies ~/rncs_data/IMR_Donnees_Saisies; quit'`

    # Ensure files permissions are correct
    `find ~/rncs_data/IMR_Donnees_Saisies/tc -type d -exec chmod 755 {} +`
    `find ~/rncs_data/IMR_Donnees_Saisies/tc -type f -exec chmod 644 {} +`
  end
end
