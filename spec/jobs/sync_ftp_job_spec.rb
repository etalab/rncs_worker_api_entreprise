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

  let(:rncs_source_path) { Rails.configuration.rncs_sources['path'] }

  describe 'sync job behaviour' do
    before do
      allow_lftp_success
      allow_chmod_success
    end

    it 'syncs TC daily updates for the current month' do
      current_month_sync_command = "mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/flux/2019/01/ -O #{rncs_source_path}/tc/flux/2019;"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(current_month_sync_command))

      subject
    end

    it 'syncs TC daily updates for the previous month' do
      previous_month_sync_command = "mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/flux/2018/12/ -O #{rncs_source_path}/tc/flux/2018;"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(previous_month_sync_command))

      subject
    end

    it 'syncs TC partial stocks for the current month' do
      current_month_sync_command = "mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/stock/2019/01/ -O #{rncs_source_path}/tc/stock/2019;"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(current_month_sync_command))

      subject
    end

    it 'syncs TC partial stocks for the previous month' do
      previous_month_sync_command = "mirror -c -P 2 -F public/IMR_Donnees_Saisies/tc/stock/2018/12/ -O #{rncs_source_path}/tc/stock/2018;"
      expect(Open3).to receive(:capture3)
        .with(a_string_including(previous_month_sync_command))

      subject
    end

    it 'changes file permissions of the files and folders to deploy after sync' do
      change_dirs_permissions_cmd = "find #{rncs_source_path} -type d -exec chmod 755 {} +"
      change_files_permissions_cmd = "find #{rncs_source_path} -type f -exec chmod 644 {} +"
      expect(Open3).to receive(:capture3).with(/lftp/).ordered
      expect(Open3).to receive(:capture3).with(change_dirs_permissions_cmd).ordered
      expect(Open3).to receive(:capture3).with(change_files_permissions_cmd).ordered

      subject
    end

    it 'does not log any error' do
      expect(Rails.logger).not_to receive(:error)
      subject
    end
  end

  # When specifying folders to sync as we do with lftp, the executed command
  # will create the targetted folders on the local file system even if they
  # are empty (because inexistant on the FTP source server). This will happen
  # a lot for partial stock folders since they can be absent for several
  # months. We purge such empty folders after the sync since we don't want
  # the code for import to fail because it founds empty folders on the disk.
  describe 'sync folders post traitment' do
    before do
      # Mock lftp system call and manually create targetted folders
      expect(Open3).to receive(:capture3)
        .and_wrap_original do |original_method, *args|
        FileUtils.mkdir_p("#{rncs_source_path}/tc/stock/2018/12")
        FileUtils.touch("#{rncs_source_path}/tc/stock/2018/12/a_file.txt")
        FileUtils.mkdir_p("#{rncs_source_path}/tc/flux/2019/01")
        ['', '', status_success]
      end

      allow_chmod_success
    end

    after { FileUtils.rm_rf("#{rncs_source_path}/tc/stock/2018/12") }

    it 'deletes empty month folder' do
      subject

      expect(Dir.exists?("#{rncs_source_path}/tc/flux/2019/01")).to eq(false)
    end

    it 'deletes empty year folder' do
      subject

      expect(Dir.exists?("#{rncs_source_path}/tc/flux/2019")).to eq(false)
    end

    it 'keeps non empty folder' do
      subject

      expect(Dir.exists?("#{rncs_source_path}/tc/stock/2018/12")).to eq(true)
    end
  end

  describe 'when lftp fails' do
    before do
      allow(Open3).to receive(:capture3).with(/lftp/).and_return(['', 'random error', status_failure])
      allow_chmod_success
    end

    it 'logs an error' do
      expect(Rails.logger).to receive(:error).with('LFTP sync failed with: random error')
      subject
    end
  end

  describe 'when chmod fails' do
    before do
      allow_lftp_success
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

  def allow_lftp_success
    allow(Open3).to receive(:capture3).with(/lftp.+/).and_return(['', '', status_success])
  end

  def status_success
    instance_double Process::Status, success?: true
  end

  def status_failure
    instance_double Process::Status, success?: false
  end
end
