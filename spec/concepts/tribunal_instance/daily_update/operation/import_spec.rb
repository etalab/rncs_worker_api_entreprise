require 'rails_helper'

describe TribunalInstance::DailyUpdate::Operation::Import, :trb do
  subject { described_class.call logger: logger }

  let(:logger) { instance_double(Logger).as_null_object }

  # spec/fixtures/titmc/flux/2017/05/18
  # ├── 0Hnni3p82a62_20170509212412TITMCFLUX
  # │   ├── 20170509212412TITMCFLUX.md5
  # │   └── 20170509212412TITMCFLUX.zip
  # [...]
  # └── 1eUKHhoF3kQT_20170515205704TITMCFLUX
  #     ├── 20170515205704TITMCFLUX.md5
  #     └── 20170515205704TITMCFLUX.zip
  describe 'success' do
    before do
      create :daily_update_with_completed_units, year: '2017', month: '05', day: '17', proceeded: true
      create :daily_update_tribunal_instance,
        year: '2017',
        month: '05',
        day: '18',
        proceeded: false,
        files_path: Rails.root.join('spec/fixtures/titmc/flux/2017/05/18')
      create :daily_update_tribunal_instance, year: '2017', month: '05', day: '19', proceeded: false
    end

    it { is_expected.to be_success }

    its([:daily_update]) { is_expected.to have_attributes year: '2017', month: '05', day: '18' }
    its([:daily_update]) { is_expected.to be_proceeded }
    its([:daily_update]) { is_expected.to have_attributes status: 'PENDING' }

    it 'saved some daily update units' do
      expect { subject }.to change(DailyUpdateUnit, :count).by 5
    end

    it 'enqueued a job for each unit' do
      units = subject[:daily_update].daily_update_units
      units.each do |unit|
        expect(ImportTitmcDailyUpdateUnitJob)
          .to have_been_enqueued.with(unit.id)
          .on_queue('rncs_worker_api_entreprise_test_titmc_daily_update')
      end
    end
  end

  describe 'when NextQueuedUpdate returns nothing' do
    it { is_expected.to be_failure }

    it 'logs' do
      expect(logger).to receive(:error).with('No updates have been queued for import.')
      subject
    end
  end

  describe 'when FetchUnits fails' do
    before do
      create(:daily_update_tribunal_instance,
        year: '2017',
        month: '05',
        day: '19',
        proceeded: false,
        files_path: Rails.root.join('spec/fixtures/titmc/flux/2017/05/19'))
    end

    it { is_expected.to be_failure }

    it 'logs' do
      expect(logger).to receive(:error).with(%r{No directory found in daily update .+/2017/05/19})
      subject
    end
  end
end
