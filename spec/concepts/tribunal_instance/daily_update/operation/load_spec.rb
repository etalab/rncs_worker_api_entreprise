require 'rails_helper'

describe TribunalInstance::DailyUpdate::Operation::Load, :trb do
  subject { described_class.call params }

  let(:params) { { logger: logger } }
  let(:logger) { instance_double(Logger).as_null_object }

  before { create :daily_update_titmc_with_completed_units, db_timestamp }

  # Folder structure
  # spec/fixtures/titmc/flux
  # └── 2017
  #     └── 05
  #         ├── 18
  #         │   ├── 0Hnni3p82a62_20170509212412TITMCFLUX
  #         │   ├── 0NKxyI4J7iuk_20170517210602TITMCFLUX
  #         │   ├── 0O09IEJ9562u_20170504204802TITMCFLUX
  #         │   ├── 0qLllJmhaRhU_20170516221805TITMCFLUX
  #         │   └── 1eUKHhoF3kQT_20170515205704TITMCFLUX
  #         ├── 19
  #         ├── 20
  #         ├── 23
  #         ├── 24
  #         └── 25
  describe 'success' do
    let(:db_timestamp) { { year: '2017', month: '05', day: '18' } }

    it { is_expected.to be_success }

    it 'logs load starts' do
      expect(logger).to receive(:info).with('Fetching new daily updates')
      subject
    end

    it 'logs the right db date' do
      expect(logger).to receive(:info).with('The database is sync until 2017-05-18.')
      subject
    end

    it 'logs how many new updates are found & created' do
      expect(logger).to receive(:info).with('5 daily updates found.')
      subject
    end

    it 'starts the import' do
      expect_to_call_nested_operation(TribunalInstance::DailyUpdate::Operation::Import)
      subject
    end

    its([:daily_updates]) { are_expected.to all be_persisted }
    its([:daily_updates]) { are_expected.to all have_attributes proceeded: false }
    its([:daily_updates]) { are_expected.to all have_attributes status: 'QUEUED' }
    its([:daily_updates]) { are_expected.to all have_attributes daily_update_units: [] }

    it 'keeps only the latest updates' do
      expect(subject[:daily_updates]).to contain_exactly(
        an_object_having_attributes(year: '2017', month: '05', day: '19'),
        an_object_having_attributes(year: '2017', month: '05', day: '20'),
        an_object_having_attributes(year: '2017', month: '05', day: '23'),
        an_object_having_attributes(year: '2017', month: '05', day: '24'),
        an_object_having_attributes(year: '2017', month: '05', day: '25'),
      )
    end

    describe 'limit option' do
      before { params[:limit] = 2 }

      it 'limit to 2 updates' do
        expect(subject[:daily_updates]).to contain_exactly(
          an_object_having_attributes(year: '2017', month: '05', day: '19'),
          an_object_having_attributes(year: '2017', month: '05', day: '20'),
        )
      end
    end
  end

  describe 'when no new updates found' do
    let(:db_timestamp) { { year: '2017', month: '05', day: '25' } }

    it { is_expected.to be_failure }

    it 'logs no new updates found' do
      expect(logger).to receive(:info).with('No daily updates available after 2017-05-25. Nothing to import.')
      subject
    end

    it 'does nothing if no new daliy updates' do
      expect { subject }.not_to change(DailyUpdateTribunalInstance, :count)
    end

    it 'does not start the import' do
      expect_not_to_call_nested_operation(TribunalInstance::DailyUpdate::Operation::Import)
      subject
    end
  end

  context 'when DBCurrentDate fails' do
    it 'is a failure'
    it 'logs an error'
  end

  context 'when FetchInPipe fails' do
    it 'is a failure'
    it 'logs an error'
  end
end
