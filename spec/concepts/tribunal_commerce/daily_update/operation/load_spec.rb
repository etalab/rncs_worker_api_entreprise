require 'rails_helper'

describe TribunalCommerce::DailyUpdate::Operation::Load do
  let(:logger) { object_double(Rails.logger, info: true).as_null_object }
  let(:op_params) { { logger: logger } }
  subject { described_class.call(op_params) }

  describe 'logger:' do
    it 'defaults to Rails.logger' do
      op_params.delete(:logger)

      expect(subject[:logger]).to eq(Rails.logger)
    end
  end

  it 'logs' do
    expect(logger).to receive(:info)
      .with('Fetching new daily updates to import...')
    subject
  end

  # Folder structure for happy path spec
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

    context 'with new updates available in pipe' do
      let(:db_timestamp) { { year: '2018', month: '04', day: '10' } }

      it { is_expected.to be_success }

      it 'logs' do
        expect(logger).to receive(:info)
          .with('The database is sync until the date 2018-04-10.')
        subject
      end

      describe 'handled updates' do
        let(:handled_updates) { subject[:daily_updates] }

        they 'are saved' do
          expect(handled_updates).to all(be_persisted)
        end

        example 'have "QUEUED" status' do
          expect(handled_updates).to all(have_attributes(status: 'QUEUED'))
        end

        they 'are not proceeded yet' do
          expect(handled_updates).to all(have_attributes(proceeded: false))
        end

        # Here daily updates are just queued for import
        # Their associated units will be created right before the import itself
        example 'have no associated units yet' do
          expect(handled_updates).to all(have_attributes(daily_update_units: []))
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

        it 'logs new updates have been found'

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
        expect(logger).to receive(:info)
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
