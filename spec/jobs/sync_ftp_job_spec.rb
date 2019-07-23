require 'rails_helper'

describe SyncFTPJob do
  subject { described_class.perform_now }

  before do
    # Freeze time in January so we directly test the most edged case :
    # new year transition with sync of the January month of the current
    # year and the sync of the December month of the previous year
    Timecop.freeze(2019, 1, 10)
  end

  after { Timecop.return }

  let(:rncs_path_prefix) { Rails.configuration.rncs_sources['path_prefix'] }
  let(:rncs_sources_path) { Rails.configuration.rncs_sources_path }
  let(:ftp_login) { Rails.application.credentials.ftp_login }
  let(:ftp_password) { Rails.application.credentials.ftp_password }

  describe 'sync job behaviour' do
    before do
      allow_wget_success
      allow_chmod_success
    end

    it 'syncs TC daily updates for the current month' do
      current_month_sync_command = "wget -r --level=8 -m --reject \"index.html\" -c -N --secure-protocol=auto --no-proxy --ftp-user='#{ftp_login}' --ftp-password='#{ftp_password}' --directory-prefix=#{rncs_path_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/flux/2019/01"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(current_month_sync_command))

      subject
    end

    it 'syncs TC daily updates for the previous month' do
      previous_month_sync_command = "wget -r --level=8 -m --reject \"index.html\" -c -N --secure-protocol=auto --no-proxy --ftp-user='#{ftp_login}' --ftp-password='#{ftp_password}' --directory-prefix=#{rncs_path_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/flux/2018/12"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(previous_month_sync_command))

      subject
    end

    it 'syncs TC partial stocks for the current month' do
      current_month_sync_command = "wget -r --level=8 -m --reject \"index.html\" -c -N --secure-protocol=auto --no-proxy --ftp-user='#{ftp_login}' --ftp-password='#{ftp_password}' --directory-prefix=#{rncs_path_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/stock/2019/01"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(current_month_sync_command))

      subject
    end

    it 'syncs TC partial stocks for the previous month' do
      previous_month_sync_command = "wget -r --level=8 -m --reject \"index.html\" -c -N --secure-protocol=auto --no-proxy --ftp-user='#{ftp_login}' --ftp-password='#{ftp_password}' --directory-prefix=#{rncs_path_prefix} --no-check-certificate ftps://opendata-rncs.inpi.fr/public/IMR_Donnees_Saisies/tc/stock/2018/12"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(previous_month_sync_command))

      subject
    end

    it 'changes file permissions of the files and folders to deploy after sync' do
      change_dirs_permissions_cmd = "find #{rncs_sources_path} -type d -exec chmod 755 {} +"
      change_files_permissions_cmd = "find #{rncs_sources_path} -type f -exec chmod 644 {} +"
      expect(Open3).to receive(:capture3).with(/wget/).ordered
      expect(Open3).to receive(:capture3).with(change_dirs_permissions_cmd).ordered
      expect(Open3).to receive(:capture3).with(change_files_permissions_cmd).ordered

      subject
    end

    it 'does not log any error' do
      expect(Rails.logger).not_to receive(:error)
      subject
    end
  end

  # When trying to download folders with wget it will create the target's
  # parent folder tree (until the year folder). Those empty year folders
  # that could appear during a new year shift are deleted.
  describe 'sync folders post traitment' do
    before do
      # Mock wget system call and manually create targetted folders
      expect(Open3).to receive(:capture3)
        .and_wrap_original do |original_method, *args|
        FileUtils.mkdir_p("#{rncs_sources_path}/tc/stock/2018/12")
        FileUtils.mkdir_p("#{rncs_sources_path}/tc/flux/2019")
        ['', '', status_success]
      end

      allow_chmod_success
    end

    after { FileUtils.remove_dir("#{rncs_sources_path}/tc/stock/2018/12") }

    it 'deletes empty year folders' do
      subject

      expect(Dir.exists?("#{rncs_sources_path}/tc/flux/2019")).to eq(false)
    end

    it 'keeps non empty year folders' do
      subject

      expect(Dir.exists?("#{rncs_sources_path}/tc/stock/2018")).to eq(true)
    end
  end

  describe 'when wget fails' do
    before do
      allow(Open3).to receive(:capture3).with(/wget/).and_return(['', 'random error', status_failure])
      allow_chmod_success
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with('WGET sync failed with: random error')
      subject
    end
  end

  describe 'when chmod fails' do
    before do
      allow_wget_success
      allow(Open3).to receive(:capture3).with(/chmod/).and_return(['', 'random error', status_failure])
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with(/Ensure permissions for .+/).twice
      subject
    end
  end

  private

  def allow_chmod_success
    allow(Open3).to receive(:capture3).with(/chmod/).and_call_original
  end

  def allow_wget_success
    allow(Open3).to receive(:capture3).with(/wget.+/).and_return(['', '', status_success])
  end

  def status_success
    instance_double Process::Status, success?: true
  end

  def status_failure
    instance_double Process::Status, success?: false
  end
end
