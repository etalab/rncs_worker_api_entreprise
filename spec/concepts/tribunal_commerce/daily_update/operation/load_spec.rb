require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Operation::Load do
  # Folder structure for the tests
  # spec/fixtures/tc/flux
  # └── 2018
  #     └── 04
  #         ├── 09
  #         ├── 10
  #         ├── 11
  #         ├── 12
  #         ├── 13
  #         ├── 14
  #         └── 18
  context 'when DBStateDate returns the timestamp of DB state' do
    before { create(:daily_update_with_completed_units, db_timestamp) }
    subject { described_class.call }

    context 'with new updates available in pipe' do
      let(:db_timestamp) { { year: '2018', month: '04', day: '10' } }

      it { is_expected.to be_success }

      describe 'handled updates' do
        let(:handled_updates) { subject[:daily_updates] }

        it 'saves updates as pending' do
          expect(handled_updates).to all(be_persisted)
          expect(handled_updates).to all(have_attributes(status: 'PENDING'))
        end

        it 'keeps latter updates only' do
          expect(handled_updates).to include(
            an_object_having_attributes(year: '2018', month: '04', day: '11'),
            an_object_having_attributes(year: '2018', month: '04', day: '12'),
            an_object_having_attributes(year: '2018', month: '04', day: '13'),
            an_object_having_attributes(year: '2018', month: '04', day: '14'),
            an_object_having_attributes(year: '2018', month: '04', day: '18'),
          )
        end

        it 'ignores older updates' do
          expect(handled_updates).to_not include(
            an_object_having_attributes(year: '2018', month: '04', day: '09'),
            an_object_having_attributes(year: '2018', month: '04', day: '10'),
          )
        end
      end

      it 'calls import'
    end

    context 'with no daily updates available in pipe' do
      let(:db_timestamp) { { year: '2018', month: '04', day: '19' } }

      it { is_expected.to be_failure }

      it 'logs there are no updates to run' do
        expect(Rails.logger).to receive(:info)
          .with('No daily updates available after `2018-04-19`. Nothing to import.')

        subject
      end
    end

    describe 'available options' do
      # TODO use TimeCop
      describe 'delay:' do
        it 'runs only updates older than the number of days provided'
        it 'defaults to 0'
      end

      describe 'limit:' do
        # default to no limit
        it 'limits the number of update to import'
      end
    end
  end

  context 'when DBStateDate fails' do
    it 'is failure'
    it 'logs the returned error message'
  end

  context 'when FetchUpdatesInPipe fails' do
    it 'is failure'
    it 'logs the error message'
  end
end
