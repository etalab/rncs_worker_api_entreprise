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
  # Partial stocks may be available as well
  # spec/fixtures/tc/stock
  # ├── 2016
  # │   └── 09
  # │       └── 28
  # ├── 2017
  # │   ├── 01
  # │   │   └── 28
  # │   └── 11
  # │       └── 08
  # └── 2018
  #     └── 04
  #         └── 12
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
          expect(handled_updates).to contain_exactly(
            an_object_having_attributes(year: '2018', month: '04', day: '11'),
            an_object_having_attributes(year: '2018', month: '04', day: '12', partial_stock?: true),
            an_object_having_attributes(year: '2018', month: '04', day: '12', partial_stock?: false),
            an_object_having_attributes(year: '2018', month: '04', day: '13'),
            an_object_having_attributes(year: '2018', month: '04', day: '14'),
            an_object_having_attributes(year: '2018', month: '04', day: '18')
          )
        end

        it 'logs new updates have been found'

        it 'ignores older updates' do
          expect(handled_updates).to_not include(
            an_object_having_attributes(year: '2018', month: '04', day: '09'),
            an_object_having_attributes(year: '2018', month: '04', day: '10')
          )
        end

        it 'ignores older partial stocks' do
          expect(handled_updates).to_not include(
            an_object_having_attributes(year: '2016', month: '09', day: '28'),
            an_object_having_attributes(year: '2017', month: '01', day: '28'),
            an_object_having_attributes(year: '2017', month: '11', day: '08')
          )
        end
      end

      it 'calls import'
    end

    context 'with no daily updates available in pipe' do
      let(:db_timestamp) { { year: '2018', month: '04', day: '19' } }

      context 'when no partial stocks are available' do
        it { is_expected.to be_failure }

        it 'logs there are no updates to run' do
          expect(logger).to receive(:info)
            .with('No daily updates available after `2018-04-19`. Nothing to import.')

          subject
        end
      end

      context 'when partial stocks are available' do
        before do
          FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures', 'tc', 'stock', '2018/04/20'))
          FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures', 'tc', 'stock', '2018/04/21'))
        end

        after do
          FileUtils.rm_rf(Rails.root.join('spec', 'fixtures', 'tc', 'stock', '2018/04/20'))
          FileUtils.rm_rf(Rails.root.join('spec', 'fixtures', 'tc', 'stock', '2018/04/21'))
        end

        it { is_expected.to be_success }

        it 'returns the partial stocks' do
          handled_updates = subject[:daily_updates]

          expect(handled_updates).to contain_exactly(
            an_object_having_attributes(
              year: '2018',
              month: '04',
              day: '20',
              partial_stock?: true,
              status: 'QUEUED',
              proceeded: false
            ),
            an_object_having_attributes(
              year: '2018',
              month: '04',
              day: '21',
              partial_stock?: true,
              status: 'QUEUED',
              proceeded: false
            )
          )
        end
      end
    end

    describe 'available options' do
      describe 'delay:' do
        # Let's say the last imported daily update was 09/04/2018
        let(:db_timestamp) { { year: '2018', month: '04', day: '09' } }

        it 'runs only updates older than the number of days provided' do
          # We are the 12/04/2018 and we want a one day delay
          # there are fixtures directories until 18/04/2018
          Timecop.freeze(Time.new(2018, 4, 12))
          op_params[:delay] = 1
          handled_updates = subject[:daily_updates]

          expect(handled_updates).to contain_exactly(
            an_object_having_attributes(year: '2018', month: '04', day: '10'),
            an_object_having_attributes(year: '2018', month: '04', day: '11')
          )
          Timecop.return
        end
      end

      describe 'limit:' do
        let(:db_timestamp) { { year: '2018', month: '04', day: '10' } }

        # default to no limit
        # A partial stock with a daily update the same day count as one
        it 'limits the number of daily update to import' do
          op_params[:limit] = 3
          handled_updates = subject[:daily_updates]

          expect(handled_updates).to contain_exactly(
            an_object_having_attributes(year: '2018', month: '04', day: '11'),
            an_object_having_attributes(year: '2018', month: '04', day: '12', partial_stock?: false),
            an_object_having_attributes(year: '2018', month: '04', day: '12', partial_stock?: true),
            an_object_having_attributes(year: '2018', month: '04', day: '13')
          )
        end
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
